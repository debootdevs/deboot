BUILDDIR = $(abspath ./build)

CONTAINER_OPTS = -v $(realpath .):/deboot -ti --rm --cap-add=SYS_PTRACE
CONTAINER_IMAGE = ghcr.io/debootdevs/fedora
CONTAINER_RELEASE = "sha256:8e9a3947a835eab7047364ec74084fc63f9d016333b4cd9fcd8a8a8ae3afd0fd"
BEE_VERSION ?= 1.18.2

ARCH = $(shell uname -m)
ifeq ($(ARCH), aarch64)
SHORT_ARCH = AA64
else ifeq ($(ARCH), x86_64)
SHORT_ARCH = X64
else
$(error Sorry, only aarch64 and x86_64 architectures are supported at the moment)
endif

KVERSION ?= $(shell find $(PREFIX)/lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)
KERNEL ?= $(PREFIX)/boot/vmlinuz-$(KVERSION)
NAME ?= Swarm Linux
KERNEL_LOADER ?= grub

.PHONY: extlinux grub install install-grub clean initramfs boot-tree

### BUILD-ENV ################################################################

build-env: env.json

env.json: Containerfile
	podman build . -t deboot-build
	podman image inspect deboot-build > $@

#init-env: env.json
#	podman run --rm -v ./:/deboot -v $(PREFIX)/boot:/boot:ro -v $(PREFIX)/lib/modules:/lib/modules:ro -ti deboot-build bash

init-env: env.json
	podman run --privileged --rm -v ./:/deboot -v /dev:/dev -ti deboot-build bash

rm-env:
	-podman rmi deboot-build
	-rm env.json

$(BUILDDIR):
	mkdir -p $@

### SYSROOT ##################################################################

SYSROOT = $(BUILDDIR)/sysroot

appliance: $(BUILDDIR)/squashfs.img $(BUILDDIR)/boot/LiveOS/squashfs.img

$(SYSROOT)/etc/os-release:
	make SYSROOT=$(SYSROOT) --directory appliance kiwi

$(BUILDDIR)/squashfs.img: $(SYSROOT)/etc/os-release $(BUILDDIR)
	mksquashfs $(SYSROOT) $@ -comp zstd -Xcompression-level 19

$(BUILDDIR)/boot/LiveOS/squashfs.img: $(BUILDDIR)/squashfs.img
	mkdir -p $(BUILDDIR)/boot/LiveOS
	cp $< $@

$(BUILDDIR)/kver: $(SYSROOT)/etc/os-release $(BUILDDIR)
	find $(SYSROOT)/lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit > $@

### BOOT-TREE ################################################################

boot-tree: $(BUILDDIR)/kver $(BUILDDIR)/boot appliance kernel initramfs loader boot-spec dtb
#	make BUILDDIR=$(BUILDDIR) KERNEL_LOADER=$(KERNEL_LOADER) --directory loader boot-tree

$(BUILDDIR)/boot: $(BUILDDIR)
	mkdir -p $@

### KERNEL ###################################################################

kernel: $(BUILDDIR)/boot/vmlinuz

$(BUILDDIR)/boot/vmlinuz: $(SYSROOT)/etc/os-release $(BUILDDIR)/boot
	cp $(SYSROOT)/lib/modules/$$(cat $(BUILDDIR)/kver)/vmlinuz $@

### INITRAMFS ################################################################

initramfs: $(BUILDDIR)/boot/initramfs

$(BUILDDIR)/boot/initramfs: $(BUILDDIR)/swarm-initrd $(BUILDDIR)/boot
	cp $< $@

$(BUILDDIR)/swarm-initrd: $(BUILDDIR)
	make BEE_VERSION=$(BEE_VERSION) BUILDDIR=$(BUILDDIR) SYSROOT=$(SYSROOT) --directory ./initramfs swarm-initrd

###### loader #######
######### GRUB #########
ifeq ($(KERNEL_LOADER), grub)
# Assume Fedora-style GRUB with support for Bootloader Spec files
boot-spec: $(BUILDDIR)/boot/loader/entries/swarm.conf $(BUILDDIR)/boot/grub2/grub.cfg

# BLS file unused for now

$(BUILDDIR)/boot/loader/entries/swarm.conf:
	mkdir -p $(@D)
	jinja2 -D name="$(NAME)" -D kernel=$(KVERSION) -D hash=$(HASH) loader/grub/bootloaderspec.conf.j2 > $@

$(BUILDDIR)/boot/grub2/grub.cfg:
	mkdir -p $(@D)
	jinja2 loader/grub/grub.cfg.j2 deboot.yaml > $@

dtb: # not sure if this is needed for GRUB boot?

loader: $(BUILDDIR)/boot/EFI/BOOT/BOOT$(SHORT_ARCH).EFI

$(BUILDDIR)/boot/EFI/BOOT/BOOT$(SHORT_ARCH).EFI: /boot/efi/EFI $(BUILDDIR)/boot
	cp -r $< $(BUILDDIR)/boot

######### U-BOOT #########
else ifeq ($(KERNEL_LOADER), u-boot)
boot-spec: $(BUILDDIR)/boot/extlinux/extlinux.conf

$(BUILDDIR)/boot/extlinux/extlinux.conf:
	mkdir -p $(@D)
	jinja2 -D name="$(NAME)" -D kernel=$(KVERSION) -D hash=$(HASH) loader/u-boot/extlinux.conf.j2 > $@

dtb: $(BUILDDIR)/boot/dtb

$(BUILDDIR)/boot/dtb: $(PREFIX)/boot/dtb
	cp -r $$(readlink -f $<) -T $@

loader: 
# U-Boot doesn't need additional loader
else
$(error Please set KERNEL_LOADER to either "grub" or "u-boot")
endif

### INSTALL INTO BOOT.IMG ####################################################

install: $(BUILDDIR)/boot.part boot-tree
	$(eval TMP := $(shell mktemp -d))
	mount $< $(TMP)
	rm -rf $(TMP)/*
	cp -r $(BUILDDIR)/boot -T $(TMP)
	umount $(TMP)
	rmdir $(TMP)

ifeq ($(KERNEL_LOADER), u-boot)
$(BUILDDIR)/boot.part: 
	loader/cp-image.sh $(BOOT_DEV) $(BUILDDIR)/boot.img $@
else
# Create loopback device backed on boot.img, devnode for p1, symlink to devnode
$(BUILDDIR)/boot.part: | $(BUILDDIR)/boot.img
	loader/init-vfat.sh $@ $|

# Allocate space and create GPT partition table with 1 partition
$(BUILDDIR)/boot.img: $(BUILDDIR)
	loader/init-image.sh $@
endif

clean:
	-rm appliance/kiwi/config.xml
	-rm -rf $(BUILDDIR)/*


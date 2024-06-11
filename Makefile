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
PKG_ARCH = amd64
else
$(error Sorry, only aarch64 and x86_64 architectures are supported at the moment)
endif

OS_ID = $(shell (. /etc/os-release && echo $ID))

BOOTFS_TEMPLATE ?= /mnt/bootfs# optionally mount template image here
NAME ?= Swarm Linux
KERNEL_LOADER ?= grub
KVERSION = $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)

.PHONY: extlinux grub install install-grub clean initramfs boot-tree

### BUILD-ENV ################################################################

build-env: env.json

env.json: Containerfile
	podman build . -t deboot-build
	podman image inspect deboot-build > $@

init-env: env.json
	podman run --privileged --rm -v ./:/deboot -v /dev:/dev -v $(BOOTFS_TEMPLATE):/bootfs:ro -ti deboot-build bash

rm-env:
	-podman rmi deboot-build
	-rm env.json

$(BUILDDIR):
	mkdir -p $@

### SYSROOT ##################################################################

SYSROOT = $(BUILDDIR)/sysroot

appliance: $(BUILDDIR)/boot/LiveOS/squashfs.img

$(SYSROOT)/etc/os-release:
	make SYSROOT=$(SYSROOT) --directory appliance kiwi

$(BUILDDIR)/squashfs.img: $(SYSROOT)/etc/os-release $(BUILDDIR)
	mksquashfs $(SYSROOT) $@ -comp zstd -Xcompression-level 19

$(BUILDDIR)/boot/LiveOS/squashfs.img: $(BUILDDIR)/squashfs.img
	mkdir -p $(BUILDDIR)/boot/LiveOS
	cp $< $@


### BOOT-TREE ################################################################

boot-tree: $(BUILDDIR)/boot appliance kernel initramfs loader boot-spec dtb
#	make BUILDDIR=$(BUILDDIR) KERNEL_LOADER=$(KERNEL_LOADER) --directory loader boot-tree

$(BUILDDIR)/boot: $(BUILDDIR)
	mkdir -p $@

### KERNEL ###################################################################

kernel: $(BUILDDIR)/boot/vmlinuz

ifeq ($(OS_ID),fedora)
$(BUILDDIR)/boot/vmlinuz: $(BUILDDIR)/boot
	cp $(SYSROOT)/lib/modules/$(KVERSION)/vmlinuz $@
else # Debian-like
$(BUILDDIR)/boot/vmlinuz: $(BUILDDIR)/boot
	cp /boot/vmlinuz-$(KVERSION) $@
endif

### INITRAMFS ################################################################

initramfs: $(BUILDDIR)/boot/initramfs

$(BUILDDIR)/boot/initramfs: $(BUILDDIR)/swarm-initrd $(BUILDDIR)/boot
	cp $< $@

$(BUILDDIR)/swarm-initrd: $(BUILDDIR)
	make BEE_VERSION=$(BEE_VERSION) BUILDDIR=$(BUILDDIR) SYSROOT=$(SYSROOT) --directory ./initramfs swarm-initrd

### loader ###################################################################
######### GRUB ###############################################################

ifeq ($(KERNEL_LOADER), grub)
# Assume Fedora-style GRUB with support for Bootloader Spec files
boot-spec: $(BUILDDIR)/boot/loader/entries/swarm.conf $(BUILDDIR)/boot/EFI/fedora/grub.cfg

# BLS file unused for now

$(BUILDDIR)/boot/loader/entries/swarm.conf:
	mkdir -p $(@D)
	jinja2 -D name="$(NAME)" -D kernel=$(KVERSION) -D hash=$(HASH) loader/grub/bootloaderspec.conf.j2 > $@

$(BUILDDIR)/boot/EFI/fedora/grub.cfg: 
	mkdir -p $(@D)
	jinja2 loader/grub/grub.cfg.j2 deboot.yaml > $@

dtb: # not sure if this is needed for GRUB boot?

loader: $(BUILDDIR)/boot/EFI/BOOT/BOOT$(SHORT_ARCH).EFI

$(BUILDDIR)/boot/EFI/BOOT/BOOT$(SHORT_ARCH).EFI: /boot/efi/EFI $(BUILDDIR)/boot
	cp -r $< $(BUILDDIR)/boot

######### U-BOOT #############################################################

else ifeq ($(KERNEL_LOADER), u-boot)
boot-spec: $(BUILDDIR)/boot/extlinux/extlinux.conf

$(BUILDDIR)/boot/extlinux/extlinux.conf:
	mkdir -p $(@D)
	jinja2 -D name="$(NAME)" -D kernel=$(KVERSION) -D hash=$(HASH) loader/u-boot/extlinux.conf.j2 > $@

dtb: $(BUILDDIR)/boot/dtb

$(BUILDDIR)/boot/dtb: /bootfs/dtb
	cp -r $$(readlink -f $<) -T $@

loader: 
# U-Boot doesn't need additional loader files

######### RASPI ##############################################################

else ifeq ($(KERNEL_LOADER), raspi)
boot-spec: $(BUILDDIR)/boot/config.txt $(BUILDDIR)/boot/cmdline.txt # sysconf.txt?

$(BUILDDIR)/boot: # target -> boot partition
	mkdir -p $@

$(BUILDDIR)/boot/config.txt: loader/raspi/config.txt $(BUILDDIR)/boot
	cp $< $@

$(BUILDDIR)/boot/cmdline.txt: loader/raspi/cmdline.txt.j2 $(BUILDDIR)/boot
	jinja2 -D hash=$(HASH) $< > $@

dtb: $(BUILDDIR)/boot/bootcode.bin

loader: $(BUILDDIR)/boot/bootcode.bin

# Not sure what these all do or if they are all needed

$(BUILDDIR)/boot/bootcode.bin: /bootfs/bootcode.bin $(BUILDDIR)/boot
	cp /bootfs/*.elf $(@D)
	cp /bootfs/*.dat $(@D)
	cp /bootfs/*.dtb $(@D)
	cp /bootfs/bootcode.bin $@

##############################################################################

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

ifneq ($(KERNEL_LOADER),grub)
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

### DOCS #######################################################

docs:
	make --directory mkdocs

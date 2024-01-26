BUILDDIR ?= $(abspath ./build)
SYSROOT = $(BUILDDIR)/sysroot

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

KVERSION ?= $(shell find $(SYSROOT)/lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)
ifeq ($(KVERSION), )
$(error No kernel found! Aborting)
endif
KERNEL ?= $(SYSROOT)/lib/modules/$(KVERSION)/vmlinuz
NAME ?= Swarm Linux
KERNEL_LOADER ?= grub

.PHONY: extlinux grub install install-grub clean initramfs boot-tree

### BOOT-TREE ################################################################

boot-tree: $(BUILDDIR)/boot loader kernel initramfs boot-spec dtb

$(BUILDDIR)/boot:
	mkdir -p $@

kernel: $(BUILDDIR)/boot/vmlinuz

$(BUILDDIR)/boot/vmlinuz: $(KERNEL) $(BUILDDIR)/boot
	cp $< $@

initramfs: $(BUILDDIR)/boot/initramfs

$(BUILDDIR)/boot/initramfs: initramfs/swarm-initrd $(BUILDDIR)/boot
	cp initramfs/swarm-initrd $@

###### loader #######
######### GRUB #########
ifeq ($(KERNEL_LOADER), grub)
# Assume Fedora-style GRUB with support for Bootloader Spec files
boot-spec: $(BUILDDIR)/boot/loader/entries/swarm.conf $(BUILDDIR)/boot/grub2/grub.cfg

$(BUILDDIR)/boot/loader/entries/swarm.conf:
	mkdir -p $(@D)
	jinja2 -D name="$(NAME)" -D kernel=$(KVERSION) -D hash=$(HASH) loader/grub/bootloaderspec.conf.j2 > $@

$(BUILDDIR)/boot/grub2/grub.cfg:
	mkdir -p $(@D)
	grub2-mkconfig -o $@

dtb: # not sure if this is needed for GRUB boot?

loader: $(BUILDDIR)/efi/EFI/BOOT/BOOT$(SHORT_ARCH).EFI

$(BUILDDIR)/efi/EFI/BOOT/BOOT$(SHORT_ARCH).EFI: $(PREFIX)/boot/efi
	cp -r $< -T $(BUILDDIR)/efi

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

### INSTALL ##################################################################

install: $(BUILDDIR)/boot.part
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
$(BUILDDIR)/boot.part: | $(BUILDDIR)/boot.img
	loader/init-vfat.sh $@ $|

$(BUILDDIR)/boot.img:
	loader/init-image.sh $@
endif

### OLD ######################################################################

$(BUILDDIR)/grub.img: initramfs/swarm-initrd
	grub/init-image.sh

$(BUILDDIR)/esp:
	make BUILDDIR=$(BUILDDIR) --directory grub

initramfs/swarm-initrd:
	make BEE_VERSION=$(BEE_VERSION) --directory ./initramfs swarm-initrd

install-grub:
	grub/mount-image.sh
	cp -r $(BUILDDIR)/esp -T $(BUILDDIR)/mnt
	# grub/unmount-image.sh
	umount $(BUILDDIR)/mnt

test-grub:
	podman run --runtime crun -v /dev:/dev $(CONTAINER_OPTS) $(CONTAINER_IMAGE) sh -c 'cd /deboot && grub/test-grub.sh'

clean:
	-rm initramfs/swarm-initrd
	-rm -rf $(BUILDDIR)/*

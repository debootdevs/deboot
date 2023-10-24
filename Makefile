BUILDDIR = $(realpath ./build)

CONTAINER_OPTS = -v $(realpath .):/deboot -ti --rm --cap-add=SYS_PTRACE
CONTAINER_IMAGE = ghcr.io/debootdevs/fedora
CONTAINER_RELEASE = "sha256:8e9a3947a835eab7047364ec74084fc63f9d016333b4cd9fcd8a8a8ae3afd0fd"
BEE_VERSION ?= 1.17.5

KVERSION ?= $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)
KERNEL ?= /lib/modules/$(KVERSION)/vmlinuz
LOADER ?= grub

.PHONY: extlinux grub install install-grub clean initramfs boot-tree

### BOOT-TREE ################################################################

boot-tree: $(BUILDDIR)/boot kernel initramfs boot-spec dtb

$(BUILDDIR)/boot:
	mkdir -p $@

kernel: $(BUILDDIR)/boot/vmlinuz

$(BUILDDIR)/boot/vmlinuz: $(BUILDDIR)/boot
	cp $(KERNEL) $@

initramfs: $(BUILDDIR)/boot/initramfs

$(BUILDDIR)/boot/initramfs: $(BUILDDIR)/boot initramfs/swarm-initrd
	cp initramfs/swarm-initrd $@

ifeq ($(LOADER), grub)
boot-spec: $(BUILDDIR)/boot/loader/entries/swarm.conf

$(BUILDDIR)/boot/loader/entries/swarm.conf:
	jinja2 -D kernel=$(KVERSION) -D hash=$(HASH) loader/grub/bootloaderspec.conf.j2

dtb:
else ifeq ($(LOADER), u-boot)
boot-spec: $(BUILDDIR)/boot/extlinux/extlinux.conf

$(BUILDDIR)/boot/extlinux/extlinux.conf:
	jinja2 -D kernel=$(KVERSION) -D hash=$(HASH) loader/u-boot/extlinux.conf.j2 > $@

dtb: $(BUILDDIR)/boot/dtb

$(BUILDDIR)/boot/dtb:
	cp -r /boot/dtb $@
else
$(error Please set LOADER to either "grub" or "u-boot")
endif

grub: $(BUILDDIR)/boot/loader/entries/ $(BUILDDIR)/boot/vmlinuz $(BUILDDIR)/boot/initramfs

### INSTALL ##################################################################

$(BUILDDIR)/boot.img:
	loader/init-image.sh $@



$(BUILDDIR)/grub.img: initramfs/swarm-initrd
	grub/init-image.sh

$(BUILDDIR)/esp:
	make BUILDDIR=$(BUILDDIR) --directory grub

initramfs/swarm-initrd:
	podman run $(CONTAINER_OPTS) $(CONTAINER_IMAGE) \
		make BEE_VERSION=$(BEE_VERSION) \
		     --directory /deboot/initramfs swarm-initrd

install:
	mount $(BUILDDIR)/boot.img $(BUILDDIR)/mnt
	install -d $(BUILDDIR)/boot $(BUILDDIR)/mnt
	umount $(BUILDDIR)/mnt

install-grub:
	grub/mount-image.sh
	cp -r $(BUILDDIR)/esp -T $(BUILDDIR)/mnt
	# grub/unmount-image.sh
	umount $(BUILDDIR)/mnt

test-grub:
	podman run --runtime crun -v /dev:/dev $(CONTAINER_OPTS) $(CONTAINER_IMAGE) sh -c 'cd /deboot && grub/test-grub.sh'

clean:
	-rm initramfs/swarm-initrd
	-rm $(BUILDDIR)/*

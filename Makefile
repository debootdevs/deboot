BUILDDIR = $(realpath ./build)

CONTAINER_OPTS = -v $(realpath .):/deboot -ti --rm --cap-add=SYS_PTRACE
CONTAINER_IMAGE = ghcr.io/debootdevs/fedora
CONTAINER_RELEASE = "sha256:8e9a3947a835eab7047364ec74084fc63f9d016333b4cd9fcd8a8a8ae3afd0fd"
BEE_VERSION ?= 1.17.2

KVERSION ?= $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)
LOADER ?= grub


$(BUILDDIR)/boot/extlinux/extlinux.conf:
	jinja2 -D kernel=$(KVERSION) -D hash=$(HASH) loader/u-boot/extlinux.conf.j2 > $@

$(BUILDDIR)/boot.img:
	loader/init-image.sh $@

MKFS_VFAT=$(PATH=/sbin:/usr/sbin:$PATH which mkfs.vfat)

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

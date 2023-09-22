BUILDDIR = $(realpath ./build)

CONTAINER_OPTS = -v $(realpath .):/deboot -ti --rm --cap-add=SYS_PTRACE
CONTAINER_IMAGE = ghcr.io/debootdevs/fedora
CONTAINER_RELEASE = "sha256:8e9a3947a835eab7047364ec74084fc63f9d016333b4cd9fcd8a8a8ae3afd0fd"
BEE_VERSION ?= 1.17.2

KVERSION = $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)

dracut/dracut-util: /usr/bin/gcc
	sh -c "cd dracut && ./configure"
	make enable_documentation=no -C dracut

grub: $(BUILDDIR)/grub.img $(BUILDDIR)/esp

$(BUILDDIR)/grub.img: initramfs/swarm-initrd
	grub/init-image.sh

$(BUILDDIR)/esp:
	make BUILDDIR=$(BUILDDIR) --directory grub

initramfs/swarm-initrd: dracut/dracut-util
	podman run $(CONTAINER_OPTS) $(CONTAINER_IMAGE) \
		make BEE_VERSION=$(BEE_VERSION) \
		     --directory /deboot/initramfs swarm-initrd

install-grub:
	grub/mount-image.sh
	cp -r $(BUILDDIR)/esp -T $(BUILDDIR)/mnt
	# grub/unmount-image.sh
	umount $(BUILDDIR)/mnt


test-grub:
	podman run --runtime crun -v /dev:/dev $(CONTAINER_OPTS) $(CONTAINER_IMAGE) sh -c 'cd /deboot && grub/test-grub.sh'

clean:
	-rm initramfs/swarm-initrd
	-rm build/*

BUILDDIR = $(realpath ./build)

CONTAINER_OPTS = -v $(realpath .):/deboot -ti --rm --cap-add=SYS_PTRACE
CONTAINER_IMAGE = ghcr.io/debootdevs/fedora
CONTAINER_RELEASE = "sha256:8e9a3947a835eab7047364ec74084fc63f9d016333b4cd9fcd8a8a8ae3afd0fd"
BEE_VERSION ?= 1.17.2

KVERSION = $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)

dracut/dracut-util: /usr/bin/gcc
	sh -c "cd dracut && ./configure"
	make enable_documentation=no -C dracut

grub: initramfs/swarm-initrd
	make BUILDDIR=/deboot/build --directory /deboot/grub

initramfs/swarm-initrd: dracut/dracut-util
	podman run $(CONTAINER_OPTS) $(CONTAINER_IMAGE) \
		make BEE_VERSION=$(BEE_VERSION) \
		     --directory /deboot/initramfs swarm-initrd

test-grub:
	podman run -v /dev:/dev $(CONTAINER_OPTS) $(CONTAINER_IMAGE) sh -c 'cd /deboot && grub/test-grub.sh'


BUILDDIR = $(realpath ./build)
MOUNTDIR = $(BUILDDIR)/mnt

ifeq ($(shell findmnt $(MOUNTDIR)),)
$(error No mount found at $(MOUNTDIR), run 'sudo grub/mount-image.sh' first!)
endif

CONTAINER_IMAGE = ghcr.io/dracutdevs/fedora
CONTAINER_RELEASE = "sha256:a9968a481821d4b2e09569e858a433d1e9b590b223383f5e9e7235525e536755"

container:
	podman image exists $(CONTAINER_IMAGE) || podman pull $(CONTAINER_IMAGE)@$(CONTAINER_RELEASE)

CONTAINER_OPTS = -v $(realpath .):/deboot -ti --rm --user 0 --cap-add=SYS_PTRACE

dracut/dracut-util: /usr/bin/gcc
	sh -c "cd dracut && ./configure"
	make enable_documentation=no -C dracut

grub: container dracut/dracut-util
	podman run -v $(realpath .)/build/mnt:/deboot/build/mnt $(CONTAINER_OPTS) $(CONTAINER_IMAGE) make BUILDDIR=/deboot/build --directory /deboot --makefile grub.Makefile

test-grub:
	podman run -v /dev:/dev $(CONTAINER_OPTS) $(CONTAINER_IMAGE) sh -c 'cd /deboot && grub/test-grub.sh'


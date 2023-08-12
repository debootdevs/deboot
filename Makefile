BUILDDIR = $(realpath ./build)
MOUNTDIR = $(BUILDDIR)/mnt
# Fedora grub prefix
GRUB_PREFIX = $(MOUNTDIR)/EFI/fedora
#GRUB_PREFIX = $(MOUNTDIR)/boot/grub2
HOST_EFI = /boot/efi
PKG_INSTALL = dnf -y install

ifeq ($(shell findmnt $(MOUNTDIR)),)
$(error No mount found at $(MOUNTDIR), run 'sudo grub/mount-image.sh' first!)
endif

CONTAINER_IMAGE = ghcr.io/dracutdevs/fedora
CONTAINER_RELEASE = "sha256:a9968a481821d4b2e09569e858a433d1e9b590b223383f5e9e7235525e536755"

container:
	podman image exists $(CONTAINER_IMAGE) || podman pull $(CONTAINER_IMAGE)@$(CONTAINER_RELEASE)

CONTAINER_OPTS = -v $(realpath .):/deboot -v $(realpath .)/build/mnt:/deboot/build/mnt -ti --rm --user 0 --cap-add=SYS_PTRACE

dracut/dracut-util: /usr/bin/gcc
	sh -c "cd dracut && ./configure"
	make enable_documentation=no -C dracut

dracutbasedir = $(realpath ./dracut)

grub: container dracut/dracut-util
	podman run $(CONTAINER_OPTS) $(CONTAINER_IMAGE) make BUILDDIR=/deboot/build --directory /deboot --makefile grub.Makefile

test-grub:
	podman run -v /dev:/dev -v $$(pwd):/deboot $(CONTAINER_IMAGE) sh -c 'cd /deboot && grub/test-grub.sh'

all: install-grub $(GRUB_PREFIX)/grub.cfg $(MOUNTDIR)/boot/vmlinuz $(MOUNTDIR)/boot/swarm-initrd

install-grub:
	$(PKG_INSTALL) grub2-efi-x64 shim-x64 
	cp -r $(HOST_EFI)/* $(MOUNTDIR)

$(GRUB_PREFIX)/grub.cfg: swarm.hash
	mkdir -p $(GRUB_PREFIX)
	grub/grub-mkconfig > $@

$(MOUNTDIR)/boot/vmlinuz:
	mkdir -p $(MOUNTDIR)/boot
	cp /lib/modules/$$KVERSION/vmlinuz $@

$(MOUNTDIR)/boot/swarm-initrd: /usr/bin/bee dracut/dracut-util
	mkdir -p $(MOUNTDIR)/boot
	$(dracutbasedir)/dracut.sh -l \
		-a "bzz network-legacy" \
		-o iscsi \
		--no-hostonly --no-hostonly-cmdline \
		-f $@ $$KVERSION

install-bee: /usr/bin/bee

/usr/bin/bee: bee-1.16.1.x86_64.rpm
	-rpm -i bee-1.16.1.x86_64.rpm

bee-1.16.1.x86_64.rpm:
	wget -nc https://github.com/ethersphere/bee/releases/download/v1.16.1/bee-1.16.1.x86_64.rpm

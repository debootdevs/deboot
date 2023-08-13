BUILDDIR = $(realpath .)/build
IMGDIR = $(BUILDDIR)/esp
# Fedora grub prefix
GRUB_PREFIX = $(IMGDIR)/EFI/fedora
#GRUB_PREFIX = $(IMGDIR)/boot/grub2
HOST_EFI = /boot/efi

CONTAINER_OPTS = -v $(realpath ..):/deboot -ti --rm
CONTAINER_NAME = ghcr.io/debootdevs/fedora
CONTAINER_RELEASE = "sha256:8e9a3947a835eab7047364ec74084fc63f9d016333b4cd9fcd8a8a8ae3afd0fd"
CONTAINER_IMAGE = $(CONTAINER_NAME)@$(CONTAINER_RELEASE)

KVERSION = $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)

all: $(GRUB_PREFIX)/grub.cfg $(IMGDIR)/boot/vmlinuz $(IMGDIR)/boot/swarm-initrd

$(GRUB_PREFIX)/grub.cfg: ../swarm.hash $(GRUB_PREFIX)
	HASHDIR=../swarm.hash ./grub-mkconfig > $@

$(GRUB_PREFIX): $(IMGDIR)
	 mkdir -p $(GRUB_PREFIX)

$(IMGDIR)/boot/swarm-initrd: $(IMGDIR)/boot ../initramfs/swarm-initrd
	cp ../initramfs/swarm-initrd $@

$(IMGDIR)/boot/vmlinuz: $(IMGDIR)/boot
	podman run $(CONTAINER_OPTS) $(CONTAINER_IMAGE) \
		make BUILDDIR=/deboot/build \
		     --directory /deboot/grub --makefile grub.Makefile

$(IMGDIR)/boot: $(IMGDIR)
	mkdir -p $(IMGDIR)/boot

$(IMGDIR):
	mkdir -p $(IMGDIR)


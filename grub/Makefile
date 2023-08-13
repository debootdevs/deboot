BUILDDIR = $(realpath .)/build
MOUNTDIR = $(BUILDDIR)/mnt
# Fedora grub prefix
GRUB_PREFIX = $(MOUNTDIR)/EFI/fedora
#GRUB_PREFIX = $(MOUNTDIR)/boot/grub2
HOST_EFI = /boot/efi

KVERSION = $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)

ifeq ($(shell findmnt $(MOUNTDIR)),)
	$(error No mount found at $(MOUNTDIR), run 'sudo grub/mount-image.sh' first!)
endif

all: install-grub $(GRUB_PREFIX)/grub.cfg $(MOUNTDIR)/boot/vmlinuz $(MOUNTDIR)/boot/swarm-initrd

install-grub:
	@echo $(KVERSION)
	cp -r $(HOST_EFI)/* $(MOUNTDIR)

$(GRUB_PREFIX)/grub.cfg: swarm.hash $(GRUB_PREFIX)
	grub/grub-mkconfig > $@

$(MOUNTDIR)/boot/vmlinuz: $(MOUNTDIR)/boot
	cp /lib/modules/$(KVERSION)/vmlinuz $@

$(MOUNTDIR)/boot/swarm-initrd: ../initramfs/swarm-initrd
	cp ../initramfs/swarm-initrd $@

$(MOUNTDIR)/boot:
	mkdir -p $(MOUNTDIR)/boot

$(GRUB_PREFIX):
	 mkdir -p $(GRUB_PREFIX)






















































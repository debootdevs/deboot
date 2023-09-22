# The part of the build that runs inside the container
BUILDDIR = $(realpath .)/build
IMGDIR = $(BUILDDIR)/esp

# Fedora grub prefix
GRUB_PREFIX = $(MOUNTDIR)/EFI/fedora
#GRUB_PREFIX = $(MOUNTDIR)/boot/grub2
HOST_EFI = /boot/efi

KVERSION = $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)

all: install-grub $(IMGDIR)/boot/vmlinuz

install-grub:
	cp -r $(HOST_EFI)/* $(IMGDIR)

$(IMGDIR)/boot/vmlinuz: $(IMGDIR)/boot
	@echo $(KVERSION)
	cp /lib/modules/$(KVERSION)/vmlinuz $@






















































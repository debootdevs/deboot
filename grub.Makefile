BUILDDIR = $(realpath ./grub/build)
MOUNTDIR = $(BUILDDIR)/mnt
# Fedora grub prefix
GRUB_PREFIX = $(MOUNTDIR)/EFI/fedora
#GRUB_PREFIX = $(MOUNTDIR)/boot/grub2
HOST_EFI = /boot/efi
PKG_INSTALL = dnf -y install

KVERSION = $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)

ifeq ($(shell findmnt $(MOUNTDIR)),)
$(error No mount found at $(MOUNTDIR), run 'sudo grub/mount-image.sh' first!)
endif

dracutbasedir = $(realpath ./dracut)

all: install-grub $(GRUB_PREFIX)/grub.cfg $(MOUNTDIR)/boot/vmlinuz $(MOUNTDIR)/boot/swarm-initrd

install-grub:
	@echo $(KVERSION)
	$(PKG_INSTALL) grub2-efi-x64 shim-x64 
	cp -r $(HOST_EFI)/* $(MOUNTDIR)

$(GRUB_PREFIX)/grub.cfg: swarm.hash
	mkdir -p $(GRUB_PREFIX)
	grub/grub-mkconfig > $@

$(MOUNTDIR)/boot/vmlinuz:
	mkdir -p $(MOUNTDIR)/boot
	cp /lib/modules/$(KVERSION)/vmlinuz $@

$(MOUNTDIR)/boot/swarm-initrd: /usr/bin/bee dracut/dracut-util
	mkdir -p $(MOUNTDIR)/boot
	$(dracutbasedir)/dracut.sh -l \
		-a "bzz network-legacy" \
		-o iscsi \
		--no-hostonly --no-hostonly-cmdline \
		-f $@ $(KVERSION)

dracut/dracut-util: /usr/bin/gcc
	sh -c "cd dracut && ./configure"
	make enable_documentation=no -C dracut

install-bee: /usr/bin/bee

/usr/bin/bee: bee-1.16.1.x86_64.rpm
	-rpm -i bee-1.16.1.x86_64.rpm

bee-1.16.1.x86_64.rpm:
	wget -nc https://github.com/ethersphere/bee/releases/download/v1.16.1/bee-1.16.1.x86_64.rpm

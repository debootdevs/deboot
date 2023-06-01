BUILDDIR = $(realpath ./grub/build)
MOUNTDIR = $(BUILDDIR)/mnt
GRUB_PREFIX = $(MOUNTDIR)/boot/grub2
HOST_EFI = /boot/efi

ifeq ($(shell findmnt $(MOUNTDIR)),)
$(error No mountdir found, run 'sudo grub/mount-image.sh' first!)
endif

dracutbasedir = $(realpath ./dracut)
PLATFORM = x86_64-efi
export GRUBFLAGS = --verbose --removable --force --target=$(PLATFORM)

all: install-grub $(GRUB_PREFIX)/grub.cfg $(MOUNTDIR)/vmlinuz $(MOUNTDIR)/swarm-initrd

install-grub: 
	cp -r $(HOST_EFI)/* $(MOUNTDIR)

$(GRUB_PREFIX)/grub.cfg:
	mkdir -p $(GRUB_PREFIX)
	grub/grub-mkconfig > $@

$(MOUNTDIR)/vmlinuz:
	cp /lib/modules/$$KVERSION/vmlinuz $@

$(MOUNTDIR)/swarm-initrd: install-bee
	$(dracutbasedir)/dracut.sh -l \
		-a "bzz network-legacy" \
		-o iscsi \
		--no-hostonly --no-hostonly-cmdline \
		-f $@ $$KVERSION

install-bee: /usr/bin/bee

/usr/bin/bee: bee-1.16.1.x86_64.rpm
	rpm -i bee-1.16.1.x86_64.rpm

bee-1.16.1.x86_64.rpm:
	wget -nc https://github.com/ethersphere/bee/releases/download/v1.16.1/bee-1.16.1.x86_64.rpm

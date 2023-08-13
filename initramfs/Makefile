BUILDDIR = $(realpath ./grub/build)
MOUNTDIR = $(BUILDDIR)/mnt

KVERSION = $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)

ifeq ($(BEE_VERSION),)
$(error Please set BEE_VERSION.)
endif

dracutbasedir = $(realpath ../dracut)

swarm-initrd: /usr/bin/bee $(dracutbasedir)/dracut-util
	$(dracutbasedir)/dracut.sh -l \
		-a "bzz network-legacy" \
		-o iscsi \
		--no-hostonly --no-hostonly-cmdline \
		-f $@ $(KVERSION)

$(dracutbasedir)/dracut-util: /usr/bin/gcc
	sh -c "cd $(dracutbasedir) && ./configure"
	make enable_documentation=no -C $(dracutbasedir)

install-bee: /usr/bin/bee

/usr/bin/bee: bee-$(BEE_VERSION).x86_64.rpm
	-rpm -i bee-$(BEE_VERSION).x86_64.rpm

bee-$(BEE_VERSION).x86_64.rpm:
	wget -nc https://github.com/ethersphere/bee/releases/download/v$(BEE_VERSION)/bee-$(BEE_VERSION).x86_64.rpm

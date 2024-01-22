KVERSION = $(shell find $(SYSROOT)/lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)
ARCH = $(shell uname -m)

ifeq ($(BEE_VERSION),)
$(error Please set BEE_VERSION.)
endif

dracutbasedir = dracut
BUILDDIR ?= .

swarm-initrd: $(BUILDDIR)/swarm-initrd

$(BUILDDIR)/swarm-initrd: $(SYSROOT)/usr/bin/bee $(dracutbasedir)/dracut-util
	mkdir -p $(SYSROOT)/$$(pwd)
	-ln -s $$(pwd)/$(dracutbasedir) $(SYSROOT)/$$(pwd)/$(dracutbasedir)
	$(dracutbasedir)/dracut.sh -l \
		-a "bzz network-legacy drm" \
		-o iscsi \
		--no-hostonly --no-hostonly-cmdline \
		--sysroot $(SYSROOT) \
		-f $@ $(KVERSION)

$(dracutbasedir)/dracut-util: /usr/bin/gcc
	sh -c "cd $(dracutbasedir) && ./configure"
	make enable_documentation=no -C $(dracutbasedir)

install-bee: $(SYSROOT)/usr/bin/bee

$(SYSROOT)/usr/bin/bee: bee-$(BEE_VERSION).$(ARCH).rpm
	-rpm -i bee-$(BEE_VERSION).$(ARCH).rpm
	-cp /usr/bin/bee $@

bee-$(BEE_VERSION).$(ARCH).rpm:
	wget -nc https://github.com/ethersphere/bee/releases/download/v$(BEE_VERSION)/bee-$(BEE_VERSION).$(ARCH).rpm

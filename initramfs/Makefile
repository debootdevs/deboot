KVERSION = $(shell find /lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)
ARCH = $(shell uname -m)
ifeq ($(ARCH),x86_64) # for bee .deb installations
ARCH = amd64
endif


ifeq ($(BEE_VERSION),)
$(error Please set BEE_VERSION.)
endif

dracutbasedir = $(abspath dracut)
BUILDDIR ?= .

swarm-initrd: $(BUILDDIR)/swarm-initrd

$(BUILDDIR)/swarm-initrd: /usr/bin/bee $(dracutbasedir)/dracut-util
	$(dracutbasedir)/dracut.sh -l \
		-a "bzz network-legacy drm" \
		-o iscsi \
		--no-hostonly --no-hostonly-cmdline \
		-f $@ $(KVERSION)

$(dracutbasedir)/dracut-util: /usr/bin/gcc
	sh -c "cd $(dracutbasedir) && ./configure"
	make enable_documentation=no --directory $(dracutbasedir)

# would not be necessary if Swarm RPM repo were kept up to date

install-bee: /usr/bin/bee

# DEBIAN

/usr/bin/bee: bee-$(BEE_VERSION).$(ARCH).deb
	-dpkg -i bee-$(BEE_VERSION).$(ARCH).deb

# NB. Bee package filename uses underscores for .deb and [-.] for .rpm. x86_64 is represented as amd64 for .deb

bee-$(BEE_VERSION).$(ARCH).deb:
	curl -sSL https://github.com/ethersphere/bee/releases/download/v$(BEE_VERSION)/bee_$(BEE_VERSION)_$(ARCH).deb -o $@

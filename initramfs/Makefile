KVERSION = $(shell find $(SYSROOT)/lib/modules -mindepth 1 -maxdepth 1 -printf "%f" -quit)
ARCH = $(shell uname -m)

$(error This build is under development. Do not use!)

ifeq ($(BEE_VERSION),)
$(error Please set BEE_VERSION.)
endif

dracutbasedir = $(abspath dracut)
BUILDDIR ?= .

swarm-initrd: $(BUILDDIR)/swarm-initrd

$(BUILDDIR)/swarm-initrd: $(SYSROOT)/usr/bin/bee $(dracutbasedir)/dracut-util
	mkdir -p $(SYSROOT)/$(dracutbasedir)
	#-ln -s $$(pwd)/$(dracutbasedir) $(SYSROOT)/$$(pwd)/$(dracutbasedir)
	#-cp -r $$(pwd)/$(dracutbasedir) $(SYSROOT)/$$(pwd)/$(dracutbasedir)
	-mount --bind $(dracutbasedir) $(SYSROOT)/$(dracutbasedir)
	-mount --bind -o ro /proc $(SYSROOT)/proc
	-mkdir -p $(SYSROOT)/$(@D) && mount --bind $(@D) $(SYSROOT)/$(@D)
	-chroot $(SYSROOT) $(dracutbasedir)/dracut.sh -l \
		-a "bzz network-legacy drm" \
		-I /usr/lib64/systemd/libsystemd-core-253.14-1.fc38.so \
		-I /usr/lib64/systemd/libsystemd-shared-253.14-1.fc38.so \
		-o iscsi \
		--no-hostonly --no-hostonly-cmdline \
		-f $@ $(KVERSION)
	umount $(SYSROOT)/$(dracutbasedir) $(SYSROOT)/$(@D) $(SYSROOT)/proc

$(dracutbasedir)/dracut-util: $(SYSROOT)/usr/bin/gcc
	mkdir -p $(SYSROOT)/$(dracutbasedir) && mount --bind $(dracutbasedir) $(SYSROOT)/$(dracutbasedir)
	-chroot $(SYSROOT) sh -c "cd $(dracutbasedir) && ./configure"
	-chroot $(SYSROOT) make enable_documentation=no --directory $(dracutbasedir)
	umount $(SYSROOT)/$(dracutbasedir)


# would not be necessary if Swarm RPM repo were kept up to date

install-bee: $(SYSROOT)/usr/bin/bee

$(SYSROOT)/usr/bin/bee: $(SYSROOT)/bee-$(BEE_VERSION).$(ARCH).rpm
	-mount --bind -o ro /dev $(SYSROOT)/dev && chroot $(SYSROOT) rpm -i bee-$(BEE_VERSION).$(ARCH).rpm
	umount $(SYSROOT)/dev

$(SYSROOT)/bee-$(BEE_VERSION).$(ARCH).rpm:
	curl -sSL https://github.com/ethersphere/bee/releases/download/v$(BEE_VERSION)/bee-$(BEE_VERSION).$(ARCH).rpm -o $@

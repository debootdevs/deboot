all: $(SYSROOT)/etc/os-release

KIWI = $(shell which kiwi || which kiwi-ng)

ifeq ($(KIWI), )
$(error Could not find kiwi. Please set Make variable KIWI to path to kiwi binary.)
endif

$(SYSROOT)/etc/os-release:
	$(KIWI) --profile Live system prepare --description . --root $(SYSROOT)

clean:
	-rm -rf $(SYSROOT)

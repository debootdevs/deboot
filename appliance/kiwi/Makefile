all: $(SYSROOT)/etc/os-release

KIWI = kiwi
#KIWI = $(shell which kiwi || which kiwi-ng)

ifeq ($(KIWI), )
$(error Could not find kiwi. Please set Make variable KIWI to path to kiwi binary.)
endif

$(SYSROOT)/etc/os-release: config.xml config.sh root
	$(KIWI) --debug --logfile=put.log --profile Live system prepare --description . --root $(SYSROOT) && touch -h $@

config.xml: config.xml.j2
	jinja2 -D arch=$$(uname -m) $< > $@

clean:
	-rm -rf $(SYSROOT)

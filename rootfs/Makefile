all: build/squashfs.img

export OS_BANNER = banner/swarmos.ans

build/squashfs.img:
	. ./mkroot.sh && build_root

test:
	. ./mkroot.sh && test_root

clean:
	rm -f build/squashfs.img
	-rmdir build

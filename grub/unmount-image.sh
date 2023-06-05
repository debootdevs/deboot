#!/bin/sh

if [ $(id -u) != 0 ]; then
	echo This script must be run as root or with sudo!
	exit 1
fi

BUILDDIR=${BUILDDIR:-./build}
BUILDDIR=$(readlink -f $BUILDDIR)
GRUB_IMG=$BUILDDIR/grub.img

LOOPDEV=$(losetup -nO NAME --associated $GRUB_IMG)
umount $BUILDDIR/mnt
losetup -d $LOOPDEV # note that this only marks the device for later destruction

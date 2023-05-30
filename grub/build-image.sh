#!/bin/sh
if [ $(id -u) != 0 ]; then
	echo This script must be run as root!
	exit 1
fi

BUILDDIR=${BUILDDIR:-./build}
BUILDDIR=$(readlink -f $BUILDDIR)
GRUB_IMG=$BUILDDIR/grub.img
GRUB_CFG=$BUILDDIR/grub.cfg
mkdir -p $BUILDDIR

GRUB_INSTALLFLAGS="--removable"

# main thread
fallocate -l 25m $GRUB_IMG
mkfs.vfat -n DEBOOT $GRUB_IMG
DEBOOT_TMPDIR=$(mktemp -dt deboot-efi.XXXXX)
mount $GRUB_IMG $DEBOOT_TMPDIR
grub2-install $GRUB_INSTALLFLAGS \
	--boot-directory=$DEBOOT_TMPDIR/boot \
	--efi-directory=$DEBOOT_TMPDIR
cp $GRUB_CFG $DEBOOT_TMPDIR/boot/grub2/grub.cfg
umount $DEBOOT_TMPDIR
rmdir $DEBOOT_TMPDIR

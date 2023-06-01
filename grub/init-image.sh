#!/bin/sh
BUILDDIR=${BUILDDIR:-./build}
BUILDDIR=$(readlink -f $BUILDDIR)
GRUB_IMG=$BUILDDIR/grub.img

MKFS_VFAT=$(PATH=/sbin:/usr/sbin:$PATH which mkfs.vfat)

mkdir -p $BUILDDIR/mnt

# main thread
fallocate -l 100m $GRUB_IMG
$MKFS_VFAT -n DEBOOT $GRUB_IMG

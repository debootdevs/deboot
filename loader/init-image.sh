#!/bin/sh

BOOT_IMG=$(readlink -f $1)

# locate mkfs.vfat
MKFS_VFAT=$(PATH=/sbin:/usr/sbin:$PATH which mkfs.vfat)

# main thread
fallocate -l 255m $BOOT_IMG
$MKFS_VFAT -n DEBOOT $BOOT_IMG

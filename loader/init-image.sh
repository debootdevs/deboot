#!/bin/sh
# locate mkfs.vfat
MKFS_VFAT=$(PATH=/sbin:/usr/sbin:$PATH which mkfs.vfat)

# main thread
fallocate -l 100m $GRUB_IMG
$MKFS_VFAT -n DEBOOT $GRUB_IMG

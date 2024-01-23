#!/bin/sh

BOOT_IMG=$1

# locate mkfs.vfat
#MKFS_VFAT=$(PATH=/sbin:/usr/sbin:$PATH which mkfs.vfat)
#SGDISK=$(PATH=/sbin:/usr/sbin:$PATH which sgdisk)

# make GPT disk image

# main thread
# fallocate -l 255m $BOOT_IMG # not supported in WSL
dd if=/dev/zero of=$BOOT_IMG bs=1M count=512
echo -e 'label: gpt\n,511M,U' | sfdisk $BOOT_IMG
#sgdisk --new=1:0:0 -t 1:ef00 $BOOT_IMG

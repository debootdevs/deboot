#!/bin/sh

BOOT_IMG=$(readlink -f $2)
BOOT_VFAT=$1

set -x

# locate mkfs.vfat
#MKFS_VFAT=$(PATH=/sbin:/usr/sbin:$PATH which mkfs.vfat)
#SGDISK=$(PATH=/sbin:/usr/sbin:$PATH which sgdisk)

# make GPT disk image

# find boot partition
LOOP_DEV=$(losetup -f $BOOT_IMG --show)
partx -a $LOOP_DEV
LOOP_PART=${LOOP_DEV}p1

# create VFAT fs
mkfs.vfat -n DEBOOT $LOOP_PART

# symlink it
( rm $BOOT_VFAT )
ln -s $LOOP_PART $BOOT_VFAT

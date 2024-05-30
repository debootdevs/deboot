#!/bin/bash
# Makes a copy of $1 to $2, then maps and symlinks the first partition to $3

SOURCE=${1-/dev/mmcblk0}
BOOT_IMG=$2
BOOT_PART=$3

dd if=$SOURCE of=$BOOT_IMG

# find boot partition
LOOP_DEV=$(losetup -f $BOOT_IMG --show)
partx -a $LOOP_DEV
LOOP_PART=${LOOP_DEV}p1
ln -s $LOOP_PART $BOOT_PART

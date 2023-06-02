#!/bin/sh

if [ $(id -u) != 0 ]; then
	echo This script must be run as root or with sudo!
	exit 1
fi

get_sudoer() {
    local SUDOER=$(ps -o ruid= -f $PPID | xargs)
    local SUDOER_PASSWD=$(getent passwd $SUDOER)
    local SUDOER_NAME=${SUDOER_PASSWD%%:*}
    local SUDOER_GROUP=$(groups $SUDOER_NAME | awk '{print $3}')
    echo $SUDOER_NAME:$SUDOER_GROUP
}

BUILDDIR=${BUILDDIR:-./build}
BUILDDIR=$(readlink -f $BUILDDIR)
GRUB_IMG=$BUILDDIR/grub.img
GRUB_CFG=$BUILDDIR/grub.cfg
mkdir -p $BUILDDIR

PLATFORM=x86_64-efi

GRUB_INSTALLFLAGS="--removable --force --target=$PLATFORM"

# main thread
fallocate -l 100m $GRUB_IMG
mkfs.vfat -n DEBOOT $GRUB_IMG
DEBOOT_TMPDIR=$(mktemp -dt deboot-efi.XXXXX)
mount $GRUB_IMG $DEBOOT_TMPDIR
grub2-install $GRUB_INSTALLFLAGS \
	--boot-directory=$DEBOOT_TMPDIR/boot \
	--efi-directory=$DEBOOT_TMPDIR

# grub.cfg
cp $GRUB_CFG $DEBOOT_TMPDIR/boot/grub2/grub.cfg

# kernel + initrd

cp /boot/vmlinuz $DEBOOT_TMPDIR/boot
cp $BUILDDIR/swarm-initrd $DEBOOT_TMPDIR/boot

umount $DEBOOT_TMPDIR
rmdir $DEBOOT_TMPDIR

chown $(get_sudoer) $GRUB_IMG

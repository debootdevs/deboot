#!/bin/sh

if [ $(id -u) != 0 ]; then
	echo This script must be run as root or with sudo!
	exit 1
fi

BUILDDIR=${BUILDDIR:-./build}
BUILDDIR=$(readlink -f $BUILDDIR)
GRUB_IMG=$BUILDDIR/grub.img

# get uid and gid of sudoer
SUDOER_UID=$(ps -o ruid= $PPID | xargs)
SUDOER_GID=$(getent passwd $SUDOER_UID)
SUDOER_GID=${SUDOER_GID#*:*:*:}
SUDOER_GID=${SUDOER_GID%%:*}

mount -o uid=$SUDOER_UID,gid=$SUDOER_GID $GRUB_IMG $BUILDDIR/mnt


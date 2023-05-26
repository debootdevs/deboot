#!/bin/sh
BIOS=${BIOS:-/usr/share/qemu/ovmf-x86_64.bin}
if [ -z $GRUB ]; then
    echo "Please set GRUB=/path/to/grub.img."
    exit 1
fi
qemu-system-x86_64 -m 512M -nographic -bios "$BIOS" -drive file="$GRUB"

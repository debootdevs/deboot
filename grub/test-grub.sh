#!/bin/sh
# Fedora
BIOS=${BIOS-/usr/share/edk2/ovmf/OVMF_CODE.fd}
# OpenSUSE
#BIOS=${BIOS:-/usr/share/qemu/ovmf-x86_64.bin}
GRUB=${GRUB:-./build/grub.img}
if [ -z $GRUB ]; then
    echo "Please set GRUB=/path/to/grub.img."
    exit 1
fi

if [-z $TEST_SUBNET ]; then
    echo "Please set TEST_SUBNET to a subnet with a route to the Internet!"
fi

mac=52:54:00:12:34:56

qemu-system-x86_64 -smp 2 -m 1024M -nographic -enable-kvm -no-reboot \
	-bios "$BIOS" -drive file="$GRUB" \
	-nic user,model=e1000,mac=$mac

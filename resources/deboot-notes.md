# DeBoot resources

## Other projects

- Dracut https://github.com/dracutdevs/dracut
- LinuxBoot (alternative to UEFI DXE phase) https://www.linuxboot.org/
- coreboot https://www.coreboot.org/

## Firmware

- https://opensourcefirmware.foundation/

## UEFI

Universal extensible firmware interface. 

An EFI executable is a PE format executable that runs in the UEFI environment.

At boot, UEFI-compliant firmware finds and loads an EFI executable in an EFI system partition (ESP) on a bootable device (configured from the UEFI/BIOS setup screen).

- EFI system partition https://en.wikipedia.org/wiki/EFI_system_partition
- iPXE firmware (has wifi, HTTP) https://ipxe.org/howto/chainloading
- EDK2 (UEFI development environment) https://github.com/tianocore/edk2
- http://www.rodsbooks.com/efi-bootloaders/index.html

## GRUB

Everyone's favourite EFI bootloader. Watch out for the GRUB Boot Hole!

- Manual https://www.gnu.org/software/grub/manual/grub/grub.html
- Netboot syntax https://olbat.net/files/misc/netboot.pdf
- Grub wifi driver (nonexistence of) https://unix.stackexchange.com/questions/631368/how-do-i-add-network-driver-to-grub
- Writing GRUB modules https://wiki.osdev.org/Writing_GRUB_Modules

## initramfs

A temporary filesystem that can be loaded into main memory during the boot process (after loading a kernel but before setting up what will become the root filesystem).

- https://wiki.gentoo.org/wiki/Custom_Initramfsn
- debugging https://wiki.debian.org/InitramfsDebug

## Secure boot

Only boot into EFI executables signed by some authority, usually the device manufacturer and/or Microsoft/Verisign.

Options for bootstrapping trust are Shim (Fedora) and PreLoader (Linux Foundation). It is also possible to add or remove signing keys.

- http://www.rodsbooks.com/efi-bootloaders/secureboot.html
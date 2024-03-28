# GRUB

The GNU Project's GRand Unified Bootloader is an interactive boot manager capable of loading Linux, BSD, and any [multiboot2](https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html)-compliant operating system kernel. It is distributed as an EFI application and as a legacy "BIOS" boot format for non-UEFI systems. Traditionally, GRUB tends to be used on x86 PCs, especially Linux systems. GRUB is extensible and a wide variety of GRUB modules are available, providing extended filesystem support (including ext4 and btrfs), video driviers, and network protocol implementations.

GRUB has a rather detailed [manual](https://www.gnu.org/software/grub/manual/grub/grub.html), but in our experience it can be difficult to get a handle on basic usage patterns from reading this. The shell scripts used by Linux distros to generate GRUB's main configuration file, `grub.cfg`, are often complex and arcane. This can make it difficult for non-expert users to diagnose and debug boot issues.

## Quickstart

The default behaviour of GRUB is to try to locate and interpret its configuration file `grub.cfg`, written in a GRUB-specific scripting language similar to Bash.

# Inspecting a raw disk image

To adapt a new device or OS to the DeBoot style boot process, it usually helps to inspect how existing OS distributions on that device do it. Apart from reading documentation, it's useful to download an official raw disk image and inspect it. This page discusses some methods to do that.

## The raw disk

Typically, bootable images are distributed as a raw image of a partitioned disk. This can take the form of a "standard" disk which is intended to be stored on a writable medium and used persistently, or a special hybrid ISO 9660 format which can also be written to an optical disk and used as an installer.

* Two mode boot extension for ISO 9660. https://en.wikipedia.org/wiki/ISO_9660#El_Torito

Generally, the `fdisk` program is used to inspect the partition tables of raw disk images, showing whether they are in MBR or GPT format and listing the partitions.

```
fdisk -l image.img
```

Typically, the last partition is the root filesystem and the earlier partitions (and sometimes some code located in the space before the first partition) are used for booting. Sometimes, the first partition is VFAT formatted and has an "EFI" partition code. In this case, UEFI firmware can discover it and launch EFI applications.

Once you have seen the layout of the disk, it's time to look inside the partitions. You can create devnodes for these partitions with the following command, which will list out the names of the devnodes: typically `/dev/mapper/loop${x}p${y}` where $y$ is the partition number and $x$ is a counter that keeps track of which loopback device you've used to do this.

```
kpartx -va image.img
```

If `kpartx`  is not available, its functionality can be replicated with `losetup` and `partx`.

## Inside the partitions

The first step is to mount and inspect the EFI system partition (ESP), if present. This can be used to figure out whether GRUB, U-Boot, or some other system is being used to boot the OS. If the image has an MBR instead of GPT, the first partition might have some other partition code like "Microsoft Basic Data."

Some tips on identifying the boot system in use:

* If the ESP is present and has a file with path `/EFI/BOOT/BOOT${ARCH}.EFI`, it can be booted by UEFI firmware.
* If GRUB is present, there is usually a file `grub${arch}.efi` somewhere in the `/EFI` directory. In this case, `grub.cfg` may be located in the ESP or in the second partition.
* EFI applications can sometimes be booted by boot code supporting a strict subset of UEFI, such as U-Boot or the Raspberry Pi bootloader (which implements EBBR).
* For non-GRUB boot sequences on ARM boards, consult the board's documentation for bootloader configuration. Configuration files are often text based and located in the first partition.
  * On U-Boot systems, look for a file `extlinux.conf`.
  * On RPi, look for `/config.txt` and `/cmdline.txt`.

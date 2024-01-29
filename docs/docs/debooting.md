# DeBooting



## Invoking

### VM

The easiest way to test your DeBoot GRUB build is to run the `grub/test-grub.sh` script from the repo root. This launches a QEMU instance with EDK2 UEFI firmware, a virtual drive backed on `boot.img`, and virtual serial console connected to the invoking terminal.

In principle the same approach could be used to test ARM/U-Boot builds, provided an emulator for the target board is available. However, this is generally a bigger ask than for x86 CPUs, where "generic" models are often sufficient.

### Metal

The other way to test this is to write `boot.img` to a removable USB drive or SD card and boot your target device from it. I use a command like 

```
sudo dd if=./build/boot.img of=/dev/sdc
```

to do this, but you can use whatever tool you usually use to create bootable USB drives.

## Using

If all goes well, the boot should take you to a GRUB menu displaying various options.

* Most of the menu items attempt to download, mount, and switch into a squashfs hosted on Swarm.
* One menu item has the phrase "local boot" in the description. This option does not use Swarm, or indeed the network, at all: it loads a local copy of the appliance artefact from the removable drive into memory and boots into that.
* The last menu item takes you back to the UEFI firmware configuration utility.

### Pitfalls

Due to various chunk extinction events that have occurred on Swarm network upgrades, not all of the options in the default configuration of the DeBoot GRUB menu are functional.

If instead of a menu you end up arriving at a GRUB prompt, it means that GRUB couldn't find its own configuration file. You can help it by running the following commands:

```sh
grub$> set prefix=${root}/grub2
grub$> normal  # Enter "normal" mode, i.e. GRUB boot menu
```

Note that the backspace key here functions like the usual behaviour of the delete key. If using QEMU with virtual serial console output, you may experience visual artefacts when using the shell; if the display gets messed up, clear it with the `clear` command.

If running via `grub/test-grub.sh`, the graphical output is not connected, and so output on the graphical terminal will not be visible. To disable the graphical terminal in initramfs, hit `e` when your target menu item is highlighted and edit the kernel commandline by deleting the expression `console=tty1`.
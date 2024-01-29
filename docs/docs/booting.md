# How booting works

Booting a computer — that is, executing code on a computer starting from a completely uninitialized, powered off state — usually traverses several stages before reaching its stable state of running operating system software. 
The job of each boot stage is to retrieve the program to execute in the next stage from wherever it is being stored, load it into memory, and execute it.
Different boot stages are distinguished by their resource footprint, user interface, the types of storage locations from which they can retrieve data, and the executable image formats they are able to load.
Generally, boot stages are designed to be *ephemeral* in the sense that they leave as little as possible behind in memory when the next stage is running.

## Booting Linux

The DeBoot POC is focussed on the task of booting Linux. Linux is usually distributed in a special gzip-compressed ELF executable format called a [b]zImage with the filename `vmlinuz`. There are various programs that can load this format; the most widely used are GRUB (for x86 systems) and U-Boot (for ARM systems). Linux can also be bundled into an EFI executable using the [EFI boot stub](https://docs.kernel.org/admin-guide/efi-stub.html) format to be loaded by UEFI (or [EBBR](https://arm-software.github.io/ebbr/)) firmware.

* We often apply the name *appliance* to the userspace images we built. In this context, an appliance is a "single-purpose OS." Of course, there is nothing about the build process that forces our images to be "single-purpose."

# Initramfs

An *initial ram filesystem* or *initramfs* is an initial stage used in the loading of Linux operating systems that offloads the job of fetching and mounting the root filesystem from the kernel to userspace tools.

```
# FEATURES

Loaders:   kernel loader, EFI 
Fetches:   *                  
Loads:     ELF executables    
Size:      10-100MB           
```

As an archive, an initramfs is a concatenated string of cpio archives, some or all of which may be gzip-compressed. 
An initramfs can be unpacked using the `cpio` utility, or inspected at a higher level using `lsinitrd`.
The `dracut-cpio` and `skipcpio` utilities are adapted specifically to unpack the cpio archives produced by dracut.

## Building the initramfs

The DeBoot project uses a fork of the [dracut](https://github.com/dracutdevs/dracut) project to generate initial ram filesystems.

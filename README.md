# DeBoot

DeBoot is a project to research and implement approaches to bootloading OS images from decentralized storage networks, such as [Swarm](https://ethswarm.org) or [IPFS](https://ipfs.tech/).

## Get involved

If you want to get involved, join [the DeBoot chat on Matrix](https://matrix.to/#/#deboot:matrix.org) or the (less active) [DeBoot chat on Telegram](https://t.me/+hd2JXtyitYw0ZWE9).

## Repo contents

`/dracut`. Submodule linking to fork of dracut with added tools for connecting to Swarm in the initramfs.

`/initramfs`. Same function as `/dracut`, but using initramfs-tools instead. Incomplete.

`/grub`. Tools for generating `grub.cfg` and making a bootable GRUB image with a menu enumerating Swarm hashes.

`/resources`. General notes on booting devices.

`/rootfs`. Scripts and Makefile for generating a simple rootfs image for testing and demonstration purposes.

`/swarm.hash`. Swarm hashes of premade rootfs.

## Running DeBoot

You'll need a KVM-ready Linux OS. Your Linux OS is KVM-ready if a file exists at `/dev/kvm`.

1. Install `podman` using [these instructions](https://podman.io/docs/installation).

2. Clone this repo using `git`, adding the `--recurse-submodules` flag.

3. Change directory to `deboot/grub`, and run the following commands:
   
   ```sh
   ./init-image.sh
   sudo ./mount-image.sh
   ```
   
   If you run the first command as root, the files created will be owned by root and you will have to go through the rest of the process as root. The second command needs to be run through `sudo`.
   
4. Download the system container image provided [here](https://github.com/dracutdevs/dracut/pkgs/container/fedora) by the dracut devs, by running:

   ```sh
   podman pull ghcr.io/dracutdevs/fedora:latest
   ```

5. Run the container image with the command:
   
   ```sh
   podman run --rm -ti --cap-add=SYS_PTRACE --user 0 \
     -v /dev:/dev -v $FULL_PATH_TO_REPO:/deboot:z \
     ghcr.io/dracutdevs/fedora:latest bash -l
   ```

   These instructions are for running rootless (i.e. as an ordinary user). If you decide to run as root as well, you need to add the `--privileged` flag or KVM will not work. For more information, see [dracut/docs/HACKING.md](https://github.com/dracutdevs/dracut/blob/master/docs/HACKING.md).
   
6. Change directory to `deboot/dracut` and run `./configure` then `make`.

7. Change directory to `..` and set the KVERSION variable to the kernel version by running `export KVERSION=$(ls /lib/modules)`.

8. Run `make`, which will generate the Swarm initramfs (`grub.cfg`) and populate the GRUB image.
    
9. Change directory to `grub`, and run `./test-grub.sh`.

   This step can be run outside the container, but you'll need to set the `BIOS` environment variable to the path to an OVMF platform firmware image. This path depends on distribution.

10. When you're done testing, clean up after yourself with `sudo ./unmount-image.sh`.

## What?

Network boot is a way to get an operating system (OS) running on your device without a bootable USB drive (or other removable media). With 10Gbps and even 100Gbps network adapters increasingly available, this can even be the fastest method to boot a device without an OS image on a storage device attached to a PCIe bus.

Typically, a network boot retrieves a bootable image from a server on the local network, which the user sets up themselves (and could be on the router itself). It uses a protocol called PXE, w

## Why?

Decentralised storage solves some liveness problems (such as censorship) with centralised hosting. With an incentivized decentralized storage solution like Swarm, files should remain available as long as hosting is funded, regardless of who is funding it, where the hosting peers are, or where the client is.

Other benefits of our system compared to net boot include:

- Operator does not need to manage hosting of the OS images
- (in some models) operator does not need a second device to act as a PXE server.

## How?

The basic challenge is this: establish a connection with a Swarm node and request a blob of data in a minimalist preboot environment. In particular, we have **no OS** available at this point. We came up several different approaches, depending on:

- Which stage in the boot process the Bee client is started up;
- How minimal an environment we load (partly determined by what is available at the boot stage we're jumping into our binary);
- Local network topology: whether the Bee client runs on the boot device itself or on a separate relay server on the LAN.

Different networking facilities are available at different stages of the boot process. The following table shows a few. (If something in the table doesn't make sense, it's because we didn't have time to make it make sense yet.)

|                  | PXE                       | UEFI executable | GrUB module       |
| ---------------- | ------------------------- | --------------- | ----------------- |
| format on device | N/A (board firmware only) | PE              | ELF (relocatable) |
| libC (syscalls)  | 🗴                         | 🗴               | 🗴                 |
| TCP              | ✓                         | ✓               | ✓                 |
| HTTP             | 🗴                         | ✓               | ✓ (with http.mod) |
| WiFi             | 🗴                         | 🗴               | 🗴                 |
| DHCP             | ✓                         | ✓               | ✓                 |
| TFTP             | ✓                         | ✓               | ✓                 |
|                  |                           |                 |                   |
|                  |                           |                 |                   |

## Exocompile approach

To get around difficulties with the limited boot environment (and to avoid doing a weird port of the Swarm client), we tried making a **unified kernel image** which bundles together a minimal Linux kernel together with enough junk to fetch a chunk from the Swarm:

- Modules/programs required for networking. This is much easier if you have an Ethernet port; you just need to add a line `"ip=:::::<interface-name>:dhcp"` to the kernel commandline (argument to `-c` in `efi-muki`). We didn't manage to get it working over WiFi yet.
- Bee client: https://github.com/ethersphere/bee
- `curl` (to make an HTTP API request from the local node).

To do this, use the `initramfs-tools` package to make an initramfs containing these components (see `./initramfs-tools/`) and then pass it and the kernel as a parameter to the `efi-mkuki` tool. Here is an example build sequence for Ubuntu (see `./initramfs-tools/`):

```sh
update-initramfs -c -k <kernel-version> 
	# creates in /boot/initrd.img-<kernel-version>
sudo efi-mkuki -c BOOT_IMAGE=/boot/vmlinuz\ 
	root=/dev/mapper/vgubuntu-root ro quiet splash vt.handoff=7 \
	break=modules  -o deboot.efi -s logo1024768.bmp \
	-S linuxx64.efi.stub /boot/vmlinuz /boot/initrd.img-<kernel-version>
# the file linuxx64.efi.stub comes from /usr/lib/systemd/boot/efi/ 
# on our machine
```

This outputs a UEFI executable `deboot.efi`, which you need to copy into your system EFI partition. Your mainboard firmware should then be able to find it, so it appears in the boot menu in the BIOS settings.

Once booted into the initramfs, you need to execute the following:

```sh
bee start --swap-enable=false --password=beanus
curl localhost:1633/bzz/<id> -LO
mount <efi-partition> esp
cp <id> esp/EFI/BOOT/nextboot.efi
exit
```


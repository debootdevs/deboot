# DeBoot - express yourself through bootloading

DeBoot is a project to research and implement approaches to bootloading OS images from decentralized storage networks, such as [Swarm](https://ethswarm.org) or [IPFS](https://ipfs.tech/).

## Milestone report

DeBoot reached the following milestones in its development:

- **Q4 2022: Proof of Concept**
  - demonstration of a minimum viable DeBoot mechanism.

- **Q2 2023: `x86-64` Support**:
  - Alpha mechanism working on x86-64 architectures. Proven in both virtual and physical hardware.
  - https://hackmd.io/@i79XZRmjR86P6AbhL0jwVQ/BJUaVuaUn

- **Q3 2023: `aarch64` Support**:
  - Alpha extended to `aarch64` architectures, proven on virtual and physical ARM device.
  -  https://hackmd.io/@i79XZRmjR86P6AbhL0jwVQ/H1kV07Ufa

- **Q4 2023: Security Model Proposal**:
  - an exploration of bootstrapping bare metal host infrastructure, and definition of a trust-oriented security model for provisioning and package management.
  - https://github.com/debootdevs/boot-survey/releases/tag/v1.0

## Get involved

If you want to get involved, join [the DeBoot chat on Matrix](https://matrix.to/#/#deboot:matrix.org) or [the DeBoot chat on Telegram](https://t.me/+hd2JXtyitYw0ZWE9).

## Repo contents

`/dracut`. Submodule linking to fork of dracut with added tools for connecting to Swarm in the initramfs.

`/initramfs`. Same function as `/dracut`, but using initramfs-tools instead. Incomplete.

`/grub`. Tools for generating `grub.cfg` and making a bootable GRUB image with a menu enumerating Swarm hashes.

`/resources`. General notes on booting devices.

`/rootfs`. Scripts and Makefile for generating a simple rootfs image for testing and demonstration purposes.

`/swarm.hash`. Swarm hashes of premade rootfs.

## Running DeBoot

You'll need a KVM-ready Linux OS. Your Linux OS is KVM-ready if a file exists at `/dev/kvm`.

1. Install the necessary packages:
   ```sh
   apt install pkg-config libkmod-dev podman dosfstools git make crun gcc+ # Debian/Ubuntu
   ```
   On an RPM-based distro, replace `libkmod-dev` with `libkmod-devel`.

2. Clone this repo using `git --recurse-submodules`.

3. Change to the repository's home directory, and run `make BEE_VERSION=$LATEST_VERSION grub` where `$LATEST_VERSION` is set to the latest version of the bee node released on https://github.com/ethersphere/bee/release (e.g. `1.17.4` at time of writing). This will create a bootable GRUB image `build/grub.img` containing our Swarm initramfs. It may take a while.
    
4. Run `sudo make install-grub` to install grub into `grub.img`.

5. To test the image you just built, run `make test-grub`. Select an item from the menu corresponding to the Swarm hash of the userspace you want to boot into.
   
   If something goes wrong and you get stuck in the QEMU console, press the sequence `<Ctrl>+a, x` to quit.

6. When you're done testing, clean up after yourself with `sudo grub/unmount-image.sh`.

## What?

Network boot is a way to get an operating system (OS) running on your device without a bootable USB drive (or other removable media). With 10Gbps and even 100Gbps network adapters increasingly available, this can even be the fastest method to boot a device without an OS image on a storage device attached to a PCIe bus.

Typically, a network boot retrieves a bootable image from a server on the local network, which the user sets up themselves (and could be on the router itself).

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


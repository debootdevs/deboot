# DeBoot

DeBoot is a project to research and implement approaches to bootloading OS images from a decentralized storage network such as Swarm or IPFS.

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

Build process:

```sh
update-initramfs <stuff>
sudo efi-mkuki <really long commandline>
```


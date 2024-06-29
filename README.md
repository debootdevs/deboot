# DeBoot - express yourself through bootloading

DeBoot is a project to research and implement techniques for booting OS images from decentralized storage networks, such as [Swarm](https://ethswarm.org) or [IPFS](https://ipfs.tech/).

## Quickstart

You'll need to obtain a bootable Raspberry Pi image to use as a template for the DeBoot build. We've tested this with the Debian RPi images (https://raspi.debian.net/tested-images/). Put the image file in the repo root directory and rename it to `template.img`. You may want to strip out unnecessary data from the image: we'll only use the data up to the end of the first partition, so you can remove the root partition using `fdisk` and `truncate` the image for faster writing to an SD card.

Now, make sure you have Podman installed and working, then run:

```sh
make init-env # enter build container
cd /deboot
make KERNEL_LOADER=raspi HASH=$SWARM_HASH install
```

to build the image.

## Documentation

Read all about the current technique in [the DeBoot documentation pages](https://debootdevs.github.io/deboot/).

## The story so far...

DeBoot reached the following milestones in its development:

- **2022 Q4: Hackathon Concept**: demonstration of a minimum viable DeBoot technique.
- **2023 Q2: `x86-64` Proof-of-Concept**: DeBoot technique for `x86-64` architecture, on VM and Baremetal. [link](https://hackmd.io/@i79XZRmjR86P6AbhL0jwVQ/BJUaVuaUn)
- **2023 Q3: `aarch64` Support**: DeBoot technique for `aarch64` architecture, on VM and Baremetal. [link](https://hackmd.io/@i79XZRmjR86P6AbhL0jwVQ/H1kV07Ufa)
- **2023 Q4: Security Model Proposal**: an exploration of bootstrapping bare metal host infrastructure, and definition of a trust-oriented security model for provisioning and package management. [link](https://github.com/debootdevs/boot-survey/releases/tag/v1.0)
- **2024 Q1: Enhanced UX**: refinement of the build and boot processes, and creation of [a user guide for the DeBoot technique](https://debootdevs.github.io/deboot/)

## Upcoming Projects

- DeBooting a Microgravity Machine/RPi – for DeSci!
- OCI Container Registry Integration
- Personalizing DeBootable Images

## Get involved

DeBoot project welcomes collaborators. If you are interested in deployment of software from decentralised storage, introduce yourself in [the DeBoot chat on Matrix](https://matrix.to/#/#deboot:matrix.org) or [the DeBoot chat on Telegram](https://t.me/+hd2JXtyitYw0ZWE9).

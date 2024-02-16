# Building the DeBoot POC

These instructions are based on the [deboot repo on github](https://github.com/debootdevs/deboot).

## Quickstart

Requires `podman`, `git`, `make`, `slirp4netns`, `uidmap` (for Debian distributions).

Clone the repo with the `--recurse-submodules` flag. Then starting from the repo root, run the following commands:

```sh
sudo make init-env
cd /deboot
make BEE_VERSION=$VERSION install
```

where `$VERSION` should be set to the latest version of the Swarm bee node as indicated by its git tag e.g. `VERSION=1.18.2`.

The main build artefacts are:

```sh
./build/boot.img      # bootable image which may be flashed to a USB drive
./build/squashfs.img  # compressed userspace which can be uploaded to Swarm and booted
```

To boot your constructed image from Swarm, first you must store it to Swarm, retrieve its Swarm hash, add an entry to `./deboot.yaml`, then rebuild `boot.img`.

Once done, you can move to the next section to start DeBooting.

To clean after yourself, run:

```sh
sudo make clean
```

## Build container

The DeBoot build is designed to run in a Fedora container using the same set of package repositories as the appliance to be built and booted. The choice of Fedora is convenient, but not necessary: with suitable modifications to package names and paths, one could adjust the build to construct appliances based on their preferred distro.

To build and enter the build environment, make sure Podman is installed and run

```
myhost:~/deboot$ sudo make init-env
...
buildenv:/$ cd /deboot
```

starting from the repo root.

### Privileges

Certain build stages require mounting a filesystem, hence root privileges in the host. That means the build environment must be run as a *privileged* container invoked by the superuser. If that makes you uncomfortable, we recommend running the entire thing in a VM.

### Version consistency

It is important that the initramfs and userspace use the same versions of packages. Crucially, the kernel modules installed in the initramfs and userspace must both exactly match the version of the loaded kernel; otherwise they cannot be loaded.

To ensure such consistency, the userspace and initramfs must be built using the same package repositories and at the same time as the build container. Unfortunately this means that the DeBoot POC boot image cannot easily

## Layout

The build processes for separate components are separated into different directories.

```sh
/appliance/kiwi/ # rootfs builder
/initramfs/         # initramfs build scripts
           dracut/  # dracut fork used to build initramfs
/loader/		# configurations for kernel loaders
        grub/    # template for grub.cfg, BLS entries
        u-boot/  # template for extlinux.conf
# other directories either deprecated or irrelevant to the build
```


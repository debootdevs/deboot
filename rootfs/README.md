# Rootfs builder

The scripts and templates in this directory can be used to generate a root filesystem or "userspace") in the compressed squashfs format used for a live OS.

## KIWI

KIWI is a system image builder maintained by SUSE. It constructs a root directory tree based on an XML spec file together with some additional customisation scripts. It can then wrap the tree in a variety of system image types.

### Users

By default, generated images have a single user `root` with password `deboot`. Additional users can be specifying more `<user/>` elements, following the pattern used for the root user. Passwords should be specified in the hashed form used in the Linux shadow database; see [`crypt(5)`](https://manpages.debian.org/unstable/libcrypt-dev/crypt.5.en.html) for a description of the format. You can generate hashes in this form using the `mkpasswd` or `openssl passwd` command-line programs.

## Legacy script

Builds a simple placeholder rootfs, encoded as a squashfs, and init script that prints a banner then drops to a shell.

Run me (rootless) in one of these containers: https://github.com/orgs/dracutdevs/packages

```sh
podman run --rm -ti --user 0 -v /dev:/dev -v $PATH_TO_REPO:/deboot:z $CONTAINER bash -l
cd /deboot/rootfs
make all test
```

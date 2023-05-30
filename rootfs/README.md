Builds a simple placeholder rootfs, encoded as a squashfs, and init script that prints a banner then drops to a shell.

Run me (rootless) in one of these containers: https://github.com/orgs/dracutdevs/packages

```sh
podman run --rm -ti --user 0 -v /dev:/dev -v $PATH_TO_REPO:/deboot:z $CONTAINER bash -l
cd /deboot/rootfs
make all test
```

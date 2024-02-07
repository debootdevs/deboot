# Appliances

We apply the name *appliance* to the userspace images we build. In this context, an appliance is a "single-purpose OS." Of course, there is nothing about the build process that actually forces our images to be "single-purpose."

## Building appliances using KIWI-NG

The DeBoot POC build uses an open-source tool called [KIWI NG](https://osinside.github.io/kiwi/), developed by SUSE, which consumes XML configuration files and scripts to build root directory trees. We then package the tree by bundling it into a [squashfs](https://docs.kernel.org/filesystems/squashfs.html) using standard Linux tool `mksquashfs`.

To build an appliance using the DeBoot build system, run `make appliance`. The output is a file `./build/squashfs.img` which can be uploaded to Swarm for later DeBooting.

The configuration directory for this appliance build is located at `./appliance/kiwi/`.

Edit the file `config.xml.j2` to:

- customize the repositories and packages installed in the appliance

- customize the users configured in the appliance
  - hashes for passwords can be generated using `openssl passwd -6`
  - default password for _root_ account is _deboot_.

Add files under `root/` for them to be included in the directory tree.

Edit the file `config.sh` to install `systemd` services

## Uploading your appliance to Swarm

To upload your appliance to Swarm, you'll need to [run a bee node](https://docs.ethswarm.org/docs/bee/working-with-bee/introduction) (light or full), purchase postage stamp batches using BZZ tokens on the Gnosis Chain network, and upload your data using the node. We recommend the use of [swarm-cli](https://github.com/ethersphere/swarm-cli) for Swarm-related operations.

### Obtaining BZZ tokens

At time of writing (2024-01-30), the most stable (i.e. having least price impact) way to obtain BZZ tokens is to purchase them directly from the issuing contract on Ethereum, which has a frontend at https://openbzz.eth.limo/. The BZZ tokens will then need to be bridged to Gnosis Chain (GC) for use with the Swarm network.

Small amounts of BZZ tokens are also available on [COWSwap](https://swap.cow.fi/).

### Purchasing postage stamp batches

You can purchase [postage stamps](https://docs.ethswarm.org/docs/learn/technology/contracts/postage-stamp) by interacting with the postage stamp contract using any GC client. This functionality is built into Swarm-CLI's `stamp` functions, which uses the GC RPC endpoint associated to your local bee node.

Stamp batch sizes are specified in terms of the "batch depth." A batch with depth *n* has a theoretical maximum storage capacity of 2<sup>n</sup> · 4KiB, however due to the way that Swarm storage space is allocated the actual amount of storage you can get in practice [may be much smaller](https://docs.ethswarm.org/docs/learn/technology/contracts/postage-stamp#effective-utilisation-table), especially for small depths. We recommend purchasing stamp batches of depth at least 26, corresponding to about 226GB of storage on average.

### Running a bee node

We recommend running bee using the official [container images](https://hub.docker.com/layers/ethersphere/bee/latest/images/sha256-c3e36ff3633e435f05fea1d81ba788465ae45ec52b1e56358ea45bd7271758a2?context=explore).

### Uploading chunks

Use the `swarm-cli upload --stamp $MYSTAMP` command.

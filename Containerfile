
FROM docker.io/library/debian AS debian-aarch64
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt -y install make gcc wget iproute2 # for installation in initramfs
RUN apt -y install systemd squashfs-tools pkg-config libkmod-dev arping sysvinit-core # for appliances, initramfs
RUN apt -y install pipx rsync curl
RUN apt -y install kiwi kmod net-tools fdisk isc-dhcp-client
RUN apt -y install $(apt-cache pkgnames linux-image | egrep 'linux-image-([0-9\.-]*)-arm64$' | tail -n 1)
RUN apt-get -y install dracut dracut-live dracut-network systemd-resolved
RUN pipx install jinja2-cli[yaml]
ENV PATH=$PATH:/root/.local/bin
# on Debian kernel package needs to know the kernel version number

FROM docker.io/library/debian AS debian-x86_64
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt -y install make gcc wget iproute2 # for installation in initramfs
RUN apt -y install systemd squashfs-tools pkg-config libkmod-dev arping sysvinit-core # for appliances, initramfs
RUN apt -y install pipx rsync curl
RUN apt -y install kiwi kmod net-tools fdisk isc-dhcp-client
RUN apt -y install $(apt-cache pkgnames linux-image | egrep 'linux-image-([0-9\.-]*)-amd64$' | tail -n 1)
RUN apt-get -y install dracut dracut-live dracut-network systemd-resolved
RUN pipx install jinja2-cli[yaml]
ENV PATH=$PATH:/root/.local/bin
# on Debian kernel package needs to know the kernel version number


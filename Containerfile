FROM registry.fedoraproject.org/fedora
RUN dnf -y install gcc wget iproute dhclient # for installation in initramfs
RUN dnf -y install kmod-devel squashfs-tools # for building and mounting rootfs
RUN dnf -y install kiwi-cli python3-jinja2-cli grub2-tools

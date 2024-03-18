FROM registry.fedoraproject.org/fedora
RUN dnf -y install gcc wget iproute dhclient # for installation in initramfs
RUN dnf -y install kernel systemd kmod-devel squashfs-tools # for appliances, initramfs
RUN dnf -y install kiwi-cli python3-jinja2-cli # for appliances
RUN dnf -y install dosfstools grub2-tools shim # for grub installation
RUN dnf -y install python3-xmltodict # for converting between XML and JSON

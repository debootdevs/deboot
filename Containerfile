FROM deb.debian.org/debian
RUN apt -y install gcc wget iproute dhclient # for installation in initramfs
RUN apt -y install kernel systemd kmod-devel squashfs-tools # for appliances, initramfs
RUN apt -y install kiwi-cli python3-jinja2-cli # for appliances
RUN apt -y install python3-xmltodict # for converting between XML and JSON

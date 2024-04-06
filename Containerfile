FROM docker.io/library/debian
RUN apt update
RUN apt -y install make gcc wget iproute2 # for installation in initramfs
RUN apt -y install systemd squashfs-tools # for appliances, initramfs
RUN apt -y install python3-xmltodict # for converting between XML and JSON
RUN apt -y install kiwi python3-jinja2 kmod net-tools fdisk
# RUN apt -y dhclient kernel # currently fails, need to replace with something for debian

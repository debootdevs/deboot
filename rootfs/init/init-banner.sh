#!/bin/sh
: > /dev/watchdog

strstr() {
	[ "${1##*"$2"*}" != "$1" ]
}

export PATH=/usr/sbin:/usr/bin:/sbin:/bin
command -v plymouth > /dev/null 2>&1 && plymouth --quit
exec > /dev/console 2>&1

export TERM=linux
export PS1='deboot:\w\$ '
stty sane

cat /etc/motd
echo "Made it to the rootfs!"

[ -c /dev/watchdog ] && printf 'V' > /dev/watchdog
strstr "$(setsid --help)" "control" && CTTY="-c"
setsid $CTTY sh -i

: > /dev/watchdog

sync
poweroff -f



























































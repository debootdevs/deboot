#/bin/bash

mkrootbasedir=${BASH_SOURCE[0]%/*}
mkrootbasedir=$(readlink -f $mkrootbasedir)
debootbasedir=$(readlink -f $mkrootbasedir/..)

if [ $dracutbasedir ]; then
    basedir=$dracutbasedir
else
    basedir=${BASH_SOURCE[0]%/*}
    basedir=$(readlink -f $basedir/../dracut)
fi
echo Using dracut installation found in $basedir.

# build directory
export BUILDDIR=${BUILDDIR:-${mkrootbasedir}/build}
mkdir -p $BUILDDIR
if [ -f $BUILDDIR/squashfs.img ]; then
    echo rootfs already found!
    exit 1
fi


make_client_root() {
    # Prepare rootfs
    ROOTFS_TMPDIR=$(mktemp -dt deboot.XXXXX)
    (
        export initdir=$ROOTFS_TMPDIR/overlay/source/
        . "$basedir"/dracut-init.sh

        (
            cd "$initdir" || exit
            mkdir -p dev sys proc etc run root usr var/lib
        )

        inst_multiple sh shutdown poweroff stty cat ps ln ip dd \
            mount dmesg mkdir cp ping grep setsid ls less cat sync \
            #findmnt find curl
        for _terminfodir in /lib/terminfo /etc/terminfo /usr/share/terminfo; do
            if [ -f "${_terminfodir}"/l/linux ]; then
                inst_multiple -o "${_terminfodir}"/l/linux
                break
            fi
        done

        inst_simple "${basedir}/modules.d/99base/dracut-lib.sh" "/lib/dracut-lib.sh"
        inst_simple "${basedir}/modules.d/99base/dracut-dev-lib.sh" "/lib/dracut-dev-lib.sh"
        inst_simple "${basedir}/modules.d/45url-lib/url-lib.sh" "/lib/url-lib.sh"
        inst_simple "${basedir}/modules.d/40network/net-lib.sh" "/lib/net-lib.sh"
        #inst_simple "${basedir}/modules.d/95nfs/nfs-lib.sh" "/lib/nfs-lib.sh"
        inst_binary "${basedir}/dracut-util" "/usr/bin/dracut-util"
        ln -s dracut-util "${initdir}/usr/bin/dracut-getarg"
        ln -s dracut-util "${initdir}/usr/bin/dracut-getargs"

        inst ${mkrootbasedir}/init/init-banner.sh /sbin/init
        inst_simple /etc/os-release
        inst /etc/passwd /etc/passwd
        inst /etc/group /etc/group
	inst $OS_BANNER /etc/motd

    )

    mksquashfs $ROOTFS_TMPDIR/overlay/source $BUILDDIR/squashfs.img -quiet -comp zstd -Xcompression-level 22
    rm -rf $ROOTFS_TMPDIR
}

make_client_root

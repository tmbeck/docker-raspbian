#!/bin/bash
#
# Script to build a raspbian docker image on Arch Linux.
#

# This is where the rootfs will be placed - don't use /tmp for this as /tmp
# is typically mounted with options nodev and nosuid (see mount(8)).
# 
BASEDIR=$(pwd)

DOCKERHOST=
DOCKERPORT=
DOCKERTAG=tbeck/raspbian:$(date +%Y%m%d)

DEFAULT_MIRROR=http://archive.raspbian.com/raspbian
MIRROR=${DBS_MIRROR:-$DEFAULT_MIRROR}

# Check and install dependencies
pacaur --needed -S binfmt-support qemu-user-static binfmt-qemu-static debootstrap arm-linux-gnueabihf-gcc

# Update qemu-binfmt
if [[ -f /etc/qemu-binfmt.conf ]]; then
	if ! grep EXTRA_OPTS /etc/qemu-binfmt.conf > /dev/null
	then
		cat << EOF >> /etc/qemu-binfmt.conf
EXTRA_OPTS="-L/usr/lib/gcc/arm-linux-gnueabihf"
EOF
	fi
else
	cat << EOF > /etc/qemu-binfmt.conf
EXTRA_OPTS="-L/usr/lib/gcc/arm-linux-gnueabihf"
EOF
fi

# Setup binfmt services
sudo systemctl restart systemd-binfmt
sudo update-binfmts --enable

# Build rootfs (this takes some time)
mkdir -p ${BASEDIR}/rootfs
fakeroot debootstrap --variant=minbase --foreign --no-check-gpg --include=ca-certificates --arch=armhf stable ${BASEDIR}/rootfs ${MIRROR}

# Cleanup and create the tarball
sudo chown -R root:root ${BASEDIR}/rootfs
sudo cp $(which qemu-arm-static) ${BASEDIR}/rootfs/usr/bin/
sudo chroot ${BASEDIR}/rootfs /debootstrap/debootstrap --second-stage --verbose
#sudo rm ${BASEDIR}/rootfs/usr/bin/qemu-arm-static

sudo chroot ${BASEDIR}/rootfs mount -t proc /proc /proc
sudo cp setup_rootfs.sh ${BASEDIR}/rootfs/
sudo chroot ${BASEDIR}/rootfs /setup_rootfs.sh
sudo umount ${BASEDIR}/rootfs/proc
sudo rm -f ${BASEDIR}/rootfs/setup_rootfs.sh

echo -n "Creating tarball..."
sudo tar -czf rootfs.tar.gz -C ${BASEDIR}/rootfs . && \
#sudo rm -rf ${BASEDIR}/rootfs
echo "done."

sudo docker build --tag ${DOCKERTAG} .

# Tag into repositories here.

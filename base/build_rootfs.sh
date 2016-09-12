#!/bin/bash
#
# Script to build a raspbian docker image on Arch Linux.
#

# This is where the rootfs will be placed - don't use /tmp for this as /tmp
# is typically mounted with options nodev and nosuid (see mount(8)). sudo is
# needed due to the device files, etc. created in the rootfs directory.
# 
# TODO Add error checking
# TODO Add ability of caller to specify docker host, port, tag, version, etc.
#
BASEDIR=$(pwd)

DOCKERHOST=
DOCKERPORT=
DOCKERNAME=tbeck/raspbian
DOCKERTAG=$(date +%Y%m%d)

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

if [[ -d ${BASEDIR}/rootfs ]]; then
	echo "${BASEDIR}/rootfs already exists! Aborting."
	exit 1
fi

# Build rootfs (this takes some time)
mkdir -p ${BASEDIR}/rootfs
sudo fakeroot debootstrap --variant=minbase --foreign --no-check-gpg --include=ca-certificates --arch=armhf stable ${BASEDIR}/rootfs ${MIRROR}

# Cleanup and create the tarball
sudo chown -R root:root ${BASEDIR}/rootfs
sudo cp $(which qemu-arm-static) ${BASEDIR}/rootfs/usr/bin/
sudo chroot ${BASEDIR}/rootfs /debootstrap/debootstrap --second-stage --verbose
#sudo rm ${BASEDIR}/rootfs/usr/bin/qemu-arm-static

# Prep the rootfs to run the setup script, then run it and cleanup.
sudo wget https://archive.raspbian.org/raspbian.public.key -O ${BASEDIR}/rootfs/raspbian.public.key
sudo chroot ${BASEDIR}/rootfs /bin/mount -t proc /proc /proc
sudo cp setup_rootfs.sh ${BASEDIR}/rootfs/
sudo chroot ${BASEDIR}/rootfs /setup_rootfs.sh
sudo umount ${BASEDIR}/rootfs/proc
sudo rm -f ${BASEDIR}/rootfs/setup_rootfs.sh
sudo rm -f ${BASEDIR}/rootfs/raspbian.public.key

# Import base filesystem into a new docker image
sudo tar -C ${BASEDIR}/rootfs -czf ${BASEDIR}/rootfs.tar.gz . && \
sudo rm -rf ${BASEDIR}/rootfs
docker build --tag ${DOCKERNAME}:${DOCKERTAG} . && \
docker tag ${DOCKERNAME}:${DOCKERTAG} ${DOCKERNAME}:latest


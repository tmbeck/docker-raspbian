# Raspbian Docker Images

This repo contains a script to build the base image (aka rootfs) for a raspbian-based Docker image. This image is suitable for use on Raspberry Pi and similar devices. Using qemu for emulation, we can run raspbian-based containers on x86 platforms. The image produced can be used to produce other docker images for specific functions. Because they are based on raspbian, they come with full access to the raspbian software library so installation of specific features is as easy as `apt-get`!

Note that by design, these docker images have no concept of raspberry pi firmware or hardware interfaces; therefore they have no direct access to hardware resources include GPIO, I2C, etc. It may still be possible to access these resources via network access or by volume mounting.

## Setup On Arch Linux

You will need to install several packages from AUR. Personally, I prefer to use pacaur for accessing packages in AUR. Replace pacaur as necessary. Installation on other distributions will be similar.

### Required Packages

1. qemu-user-static (needed for qemu-arm-static)
2. binfmt-support
3. binfmt-qemu-static
4. debootstrap
5. arm-linux-gnueabihf-gcc

* qemu and binfmt are used to enable native execution of armhf from an x86 machine.
* debootstrap is, of course, used to generate the rootfs

### Setup binfmt

To get binfmt working:

Create/edit /etc/qemu-binfmt.conf:

```console
EXTRA_OPTS="-L/usr/lib/gcc/arm-linux-gnueabihf"
```

To get binfmt working without rebooting:

```console
$ sudo systemctl restart systemd-binfmt
$ sudo update-binfmts --enable
```

To verify binfmt is setup properly for arm:

```console
$ cat /proc/sys/fs/binfmt_misc/qemu-arm
enabled
interpreter /usr/bin/qemu-arm-static
flags: OC
offset 0
magic 7f454c4601010100000000000000000002002800
mask ffffffffffffff00fffffffffffffffffeffffff
```

### Troubleshooting

Note that if binfmt is not configured properly, you will see errors such as:

```console
[tbeck@hamburgler base]$ sudo chroot rootfs/ \
> /debootstrap/debootstrap --second-stage --verbose
chroot: failed to run command ‘/debootstrap/debootstrap’: Exec format error
```

* Be sure to restart systemd-binfmt and update-binfmts.

```console
$ rootfs/bin/ls
/lib/ld-linux-armhf.so.3: No such file or directory
```

* Be sure that the /etc/qemu-binfmt.conf file has EXTRA_OPTS set to the right path. On arch, this path is usually somewhere in /usr/lib/gcc/<tuplet>, e.g. /usr/lib/gcc/arm-linux-gnueabihf

You should now be ready to proceed.

## Installing a local rootfs

We use fakeroot and debootstrap to build a raspbian-based rootfs.

### Stage 1

```console
$ mkdir rootfs
$ fakeroot debootstrap --foreign --no-check-gpg --include=ca-certificates --arch=armhf stable rootfs http://archive.raspbian.com/raspbian
```

This will setup the stable (currently jessie) raspbian into the directory rootfs. The command may take some time to complete.

Add qemu-arm-static temporarily to enable execution within the chroot environment:

```console
$ cp `which qemu-arm-static` rootfs/usr/bin/
```

### Stage 2

Now fixup permissions and run the second-stage (configure) bootstrap:

```console
$ sudo chown -R root:root rootfs
$ sudo chroot rootfs /debootstrap/debootstrap --second-stage --verbose
```

This will take some time to complete as well.

### Cleanup & Other Considerations

At this point, we have enough to get going for Docker - users wishing to build their own raspberry pi environment would continue to add the rpi firmware, kernel, and boot files. Since docker images require none of these, we'll skip them.

```console
$ sudo rm rootfs/usr/bin/qemu-arm-static
```

### Create rootfs tarball

Before you tar the rootfs, consider tidying up a bit. If you're ready to proceed, you can build the `rootfs.tar.gz` file that will be the basis of our docker image:

```console
$ sudo tar -czf rootfs.tar.gz -C rootfs .
```

## Rootfs Cleanup Notes

* TODO


## Building the container

To build the container, copy of the rootfs.tar.gz file into the docker context (where the Dockerfile is) and in the same directory run

```console
$ docker build .
```

Don't forget to docker tag, docker push, and docker pull as needed!

## Running the container

Run the container just like you would any other docker container:

```console
$ docker run -it <image> /bin/bash
```

Is sufficient to get you to a prompt. Note that this container should be executable on the x86 machine you setup binfmt on as well as your Raspberry Pi targets!



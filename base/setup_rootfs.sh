#!/bin/bash

export PATH=/bin:/sbin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin
export LANGUAGE=en_US
export DEBIAN_FRONTEND=noninteractive
echo "LC_ALL=en_US" >> /etc/environment
echo "DEBIAN_FRONTEND=noninteractive" >> /etc/environment

# This all breaks the installation of openjdk
# update-alternatives: error: error creating symbolic link `/usr/share/man/man1/rmid.1.gz.dpkg-tmp': No such file or directory
cat << EOF > /etc/dpkg/dpkg.cfg.d/01_nodoc
# Taken from http://askubuntu.com/questions/129566/remove-documentation-to-save-hard-drive-space
path-exclude /usr/share/doc/*
# we need to keep copyright files for legal reasons
path-include /usr/share/doc/*/copyright
path-exclude /usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*
# lintian stuff is small, but really unnecessary
path-exclude /usr/share/lintian/*
path-exclude /usr/share/linda/*
EOF

cat /raspbian.public.key | apt-key add -
echo "deb http://archive.raspbian.org/raspbian stable main contrib non-free" > /etc/apt/sources.list
apt-get update && apt-get dist-upgrade -y

echo "localepurge localepurge/nopurge multiselect en, en_US.UTF-8" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -y localepurge
echo -e "MANDELETE\nDONTBOTHERNEWLOCALE\nSHOWFREEDSPACE\nen_US\nen_US.ISO-8859-15\nen_US.UTF-8\n" > /etc/locale.nopurge
localepurge
apt-get purge -y localepurge
apt-get autoremove -y

apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Frees up about 14 MB
find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true
find /usr/share/doc -empty|xargs rmdir || true
rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/*
rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*


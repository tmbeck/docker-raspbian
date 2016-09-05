#!/bin/bash

export PATH=/bin:/sbin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin
export LANGUAGE=en_US

wget https://archive.raspbian.org/raspbian.public.key -O - | apt-key add -
echo "deb http://archive.raspbian.org/raspbian stable main contrib non-free" > /etc/apt/sources.list
apt-get update && apt-get dist-upgrade -y

echo "localepurge localepurge/nopurge multiselect en, en_US.UTF-8, en_US.ISO-8859-15, en_US" | debconf-set-selections
apt-get install -y localepurge
echo -e "MANDELETE\nDONTBOTHERNEWLOCALE\nSHOWFREEDSPACE\nen_US\nen_US.ISO-8859-15\nen_US.UTF-8\n" > /etc/locale.nopurge
localepurge
apt-get purge localepurge
apt-get autoremove -y

apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


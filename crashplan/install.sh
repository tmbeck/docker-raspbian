#!/bin/bash
#
# Installation script for CrashPlan 4.7.0 (Linux)
#
# Adapted from CrashPlan's install.sh script.
#
# Note that local storage (within the container) will be in $MANIFESTDIR (which
# defaults to /usr/local/var/crashplan. If running a client which will receive
# data, be sure to use a data container or -v $HOSTDIR:/usr/local/var/crashplan
#

# Where the installation tarball is extracted to.
INSTALL_DIR=/crashplan-install

# Where crashplan will be installed to.
PARENT_DIR=/usr/local

# Must source install.defaults
cd ${INSTALL_DIR}
source ./install.defaults

# Arrange directories
TARGETDIR=${PARENT_DIR}/${DIR_BASENAME}
BINSDIR=${PARENT_DIR}/bin
MANIFESTDIR=${PARENT_DIR}/var/${DIR_BASENAME}
LOGDIR=${TARGETDIR}/log

mkdir -p ${TARGETDIR}
mkdir -p ${BINSDIR}
mkdir -p ${MANIFESTDIR}
mkdir -p ${LOGDIR} && chmod 777 ${LOGDIR}

# Update xml for local storage location
# $MANIFESTDIR is the directory incoming data will be stored at. 
if grep "<manifestPath>.*</manifestPath>" ${TARGETDIR}/conf/default.service.xml > /dev/null
        then
                sed -i "s|<manifestPath>.*</manifestPath>|<manifestPath>${MANIFESTDIR}</manifestPath>|g" ${TARGETDIR}/conf/default.service.xml
        else
                sed -i "s|<backupConfig>|<backupConfig>\n\t\t\t<manifestPath>${MANIFESTDIR}</manifestPath>|g" ${TARGETDIR}/conf/default.service.xml
fi


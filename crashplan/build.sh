#!/bin/sh

wget https://download1.code42.com/installs/linux/install/CrashPlan/CrashPlan_4.7.0_Linux.tgz
docker build --tag docker.timbeckistan.com:5000/tbeck/rpi-crashplan:4.7.0 .

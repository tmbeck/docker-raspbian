#!/bin/sh

docker pull tbeck/raspbian:latest
[ ! -f CrashPlan_4.7.0_Linux.tgz ] && wget https://download1.code42.com/installs/linux/install/CrashPlan/CrashPlan_4.7.0_Linux.tgz
docker build --tag tbeck/rpi-crashplan:4.7.0 .

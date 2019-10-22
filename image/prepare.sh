#!/bin/bash

#
# Use this script to prepare a docker build process.
# This script expects /build/cleanup.sh to be run at the end of the build process.
#
# Usage in cyledge/base based Dockerfile:
#
#     FROM cyledge/base
#     ...
#     RUN /build/prepare.sh
#     ...
#     <your container build code here>
#     ...
#     RUN /build/cleanup.sh
#
#


set -e
. /build/buildconfig
. /usr/local/share/cyLEDGE/bash-library
. /etc/lsb-release


## Enable Ubuntu Universe, Multiverse, and deb-src for main.
sed -i 's/^#\s*\(deb.*main restricted\)$/\1/g' /etc/apt/sources.list
sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list


## Fix some issues with APT packages.
## See https://github.com/dotcloud/docker/issues/1024
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

## Replace the 'ischroot' tool to make it always return true.
## Prevent initscripts updates from breaking /dev/shm.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## https://bugs.launchpad.net/launchpad/+bug/974584
dpkg-divert --local --rename --add /usr/bin/ischroot
ln -sf /bin/true /usr/bin/ischroot


if [ "$IMAGE_BUILD_DEBUG" -eq 0 ]; then

  status "Loading APT catalog..."
  apt_update

  status "Upgrading all available packages..."
  apt_upgrade

else

  status "IMAGE_DEBUG enabled. Skipping ATP catalog loading..."

fi


status "Install apt tools..."
## Install HTTPS support for APT.
apt_install apt-transport-https ca-certificates software-properties-common


## Fix locale.
apt_install language-pack-en
locale-gen en_US
update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
echo -n en_US.UTF-8 > /etc/container_environment/LANG
echo -n en_US.UTF-8 > /etc/container_environment/LC_CTYPE


## Install a syslog daemon and logrotate.
IMAGE_DISABLE_SYSLOG=${IMAGE_DISABLE_SYSLOG:-0}
[ "$IMAGE_DISABLE_SYSLOG" -eq 0 ] && /build/services/syslog-ng/install.sh || true

## Install cron daemon.
IMAGE_DISABLE_CRON=${IMAGE_DISABLE_CRON:-0}
[ "$IMAGE_DISABLE_CRON" -eq 0 ] && /build/services/cron/install.sh || true

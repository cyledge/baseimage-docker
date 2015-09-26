#!/bin/bash

#
# Use this script to prepare a docker build process.
# This script expects /build/cleanup.sh to be run at the end of the build process.
#
# Usage in base image based Dockerfile:
#
#     FROM cyledge/base
#     ...
#     <your container build code here>
#     ...
#     RUN /build/cleanup.sh
#     CMD ["/sbin/my_init"]
#
#
#
# Usage in plain Dockerfile:
#
#     ADD . /build
#     RUN /build/prepare.sh
#     ...
#     <your container build code here>
#     ...
#     RUN /build/cleanup.sh
#


set -e
. /build/buildconfig

## Temporarily disable dpkg fsync to make building faster.
if [[ ! -e /etc/dpkg/dpkg.cfg.d/docker-apt-speedup ]]; then
	echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
fi

## Prevent initramfs updates from trying to run grub and lilo.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
mkdir -p /etc/container_environment
echo -n no > /etc/container_environment/INITRD

## Enable Ubuntu Universe and Multiverse.
sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list


echo "loading APT catalog..."
apt_update


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

echo "purging ubuntu base packages not used in a container..."
apt_remove_if_installed eject
apt_remove_if_installed ntpdate
apt_remove_if_installed resolvconf


echo "installing apt tools useful to build images..."
apt_install apt-transport-https ca-certificates software-properties-common


## Upgrade all packages.
echo "upgrading all available packages..."
apt_upgrade

## Fix locale.
apt_install language-pack-en
locale-gen en_US
update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
echo -n en_US.UTF-8 > /etc/container_environment/LANG
echo -n en_US.UTF-8 > /etc/container_environment/LC_CTYPE

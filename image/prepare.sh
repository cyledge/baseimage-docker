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


## Enable Ubuntu Universe and Multiverse.
sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list


if [ "$IMAGE_BUILD_DEBUG" -eq 0 ]; then

  status "Loading APT catalog..."
  apt_update

  status "Upgrading all available packages..."
  apt_upgrade

else

  status "IMAGE_DEBUG enabled. Skipping ATP catalog loading..."

fi




## Install a syslog daemon and logrotate.
[ "$IMAGE_DISABLE_SYSLOG" -eq 0 ] && /build/services/syslog-ng/syslog-ng.sh || true

## Install cron daemon.
[ "$IMAGE_DISABLE_CRON" -eq 0 ] && /build/services/cron/cron.sh || true

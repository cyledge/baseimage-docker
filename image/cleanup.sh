#!/bin/bash

#
# Use this script to finish a docker build process.
# This script expects /build/prepare.sh to be run
# before.
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


# boilerplate
set -e
. /build/buildconfig
. /usr/local/share/cyLEDGE/bash-library

if [ "$IMAGE_BUILD_DEBUG" -ne 0 ]; then
  status "IMAGE_DEBUG enabled. Skipping cleanup..."
  exit 0
fi

# remove additional apt packages - they won't be used after setup.
apt_remove apt-transport-https apt-utils python-apt-common python3-apt
# dependent per Ubuntu release:
apt_remove_if_installed libapt-inst1.5


# clean apt caches
apt-get clean -y
apt-get autoclean -y
apt-get autoremove -y

# clean up setup directories
rm -rf /build
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*
rm -f /etc/dpkg/dpkg.cfg.d/docker-apt-speedup

# clean up python bytecode
￼find / -name *.pyc -delete
￼find / -name *__pycache__* -delete

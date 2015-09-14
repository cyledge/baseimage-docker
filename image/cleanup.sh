#!/bin/bash

#
# Use this script to finish a docker build process.
# This script expects /build/prepare.sh to be run
# before. (What's done automatically if this base image
# is used.)
#
# Usage in base image based Dockerfile:
#
#     FROM cyledge/base
#     ...
#     <your container build code here>
#     ...
#     RUN /build/cleanup.sh
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


# boilerplate
set -e
. /build/buildconfig

# remove additional apt packages - they won't be used after setup.
apt_remove apt-transport-https apt-utils libapt-inst1.5 python-apt-common python3-apt

# clean apt caches
apt-get clean -y
apt-get autoclean -y
apt-get autoremove -y

# clean up setup directories
rm -rf /build
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*
rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup

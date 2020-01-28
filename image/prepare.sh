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
. /usr/local/share/cyledge/bash-library
. /etc/lsb-release




if [ "$IMAGE_BUILD_DEBUG" -eq 0 ]; then

  status "Loading APT catalog..."
  apt_update

  status "Upgrading all available packages..."
  apt_upgrade

else

  status "IMAGE_DEBUG enabled. Skipping ATP catalog loading..."

fi


status "Installing locale tools..."

if [ ${LOCALE:0:5} != "en_US" ]
then
  # install language pack for non-default languages/locales
  apt_install language-pack-${LOCALE:0:2}
else
  echo "locales locales/default_environment_locale string $LOCALE" | debconf-set-selections
  echo "locales locales/locales_to_be_generated string $LOCALE ${LOCALE##*.}" | debconf-set-selections
  apt_install locales
fi
apt_install tzdata
update-locale LANG=$LOCALE

status "Setting locale to $LOCALE"
echo -n $LOCALE > /etc/container_environment/LANG

status "Setting LANGUAGE to $LANGUAGE"
echo -n $LANGUAGE > /etc/container_environment/LANGUAGE

status "Setting timezone to $TZ"
ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime


status "Install apt tools..."
## Install HTTPS support for APT.
apt_install apt-transport-https ca-certificates software-properties-common gpg-agent dirmngr
## Mark python3 package as manually installed - could get lost in auto-cleanup otherwise.
apt_install python3

## Install a syslog daemon and logrotate.
IMAGE_DISABLE_SYSLOG=${IMAGE_DISABLE_SYSLOG:-0}
[ "$IMAGE_DISABLE_SYSLOG" -eq 0 ] && /build/services/syslog-ng/install.sh || true

## Install cron daemon.
IMAGE_DISABLE_CRON=${IMAGE_DISABLE_CRON:-0}
[ "$IMAGE_DISABLE_CRON" -eq 0 ] && /build/services/cron/install.sh || true

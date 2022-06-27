#!/bin/bash
set -e
. /build/buildconfig
. /usr/local/share/cyledge/bash-library

status "Installing cron..."

apt_install cron bc
mkdir /etc/service/cron
chmod 600 /etc/crontab
cp /build/services/cron/run.sh /etc/service/cron/run


## Remove useless cron entries.
# Checks for lost+found and scans for mtab.
rm -f /etc/cron.daily/standard
rm -f /etc/cron.daily/upstart
rm -f /etc/cron.daily/dpkg
rm -f /etc/cron.daily/apt-compat
rm -f /etc/cron.daily/password
rm -f /etc/cron.weekly/fstrim


# install vacuum-tmp cronjob
IMAGE_DISABLE_TMP_VACUUM=${IMAGE_DISABLE_TMP_VACUUM:-0}
[ "$IMAGE_DISABLE_TMP_VACUUM" -eq 0 ] && cp /build/bin/vacuum-tmp /etc/cron.hourly/vacuum-tmp || true

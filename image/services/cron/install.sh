#!/bin/bash
set -e
. /build/buildconfig
. /usr/local/share/cyledge/bash-library

status "Installing cron..."

apt_install cron
mkdir /etc/service/cron
chmod 600 /etc/crontab
cp /build/services/cron/run.sh /etc/service/cron/run

## Remove useless cron entries.
# Checks for lost+found and scans for mtab.
rm -f /etc/cron.daily/standard
rm -f /etc/cron.daily/upstart
rm -f /etc/cron.daily/dpkg
rm -f /etc/cron.daily/password
rm -f /etc/cron.weekly/fstrim

#!/bin/bash
set -e
. /build/buildconfig
. /build/bash-library


status "Setting up runit & my_init..."

## Install init process.
cp /build/bin/my_init /sbin/
mkdir -p /etc/my_init.d
mkdir -p /etc/container_environment
touch /etc/container_environment.sh
touch /etc/container_environment.json
chmod 700 /etc/container_environment

groupadd -g 8377 docker_env
chown :docker_env /etc/container_environment.sh /etc/container_environment.json
chmod 640 /etc/container_environment.sh /etc/container_environment.json
ln -s /etc/container_environment.sh /etc/profile.d/

## Install runit.
apt_install runit

## Install a syslog daemon and logrotate.
[ "$DISABLE_SYSLOG" -eq 0 ] && /build/services/syslog-ng/syslog-ng.sh || true

## Install cron daemon.
[ "$DISABLE_CRON" -eq 0 ] && /build/services/cron/cron.sh || true

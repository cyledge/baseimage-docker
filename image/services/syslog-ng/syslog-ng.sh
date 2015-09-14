#!/bin/bash
set -e
. /build/buildconfig

SYSLOG_NG_BUILD_PATH=/build/services/syslog-ng

## Install a syslog daemon.
apt_install syslog-ng-core
mkdir /etc/service/syslog-ng
cp $SYSLOG_NG_BUILD_PATH/syslog-ng.runit /etc/service/syslog-ng/run
cp $SYSLOG_NG_BUILD_PATH/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

chown syslog:syslog /var/lib/syslog-ng
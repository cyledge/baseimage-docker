#!/bin/bash
set -e
. /usr/local/share/cyLEDGE/bash-library

# If /dev/log is either a named pipe or it was placed there accidentally,
# e.g. because of the issue documented at https://github.com/phusion/baseimage-docker/pull/25,
# then we remove it.
if [ ! -S /dev/log ]; then rm -f /dev/log; fi
if [ ! -S /var/lib/syslog-ng/syslog-ng.ctl ]; then rm -f /var/lib/syslog-ng/syslog-ng.ctl; fi


. /etc/os-release

if [ "$VERSION_ID" == "12.04" ]; then
  # use syslog-ng config modified for Ubuntu 12.04
  SYSLOG_CONF=/tmp/syslog-ng.conf
else
  SYSLOG_CONF=/etc/syslog-ng/syslog-ng.conf
fi


status "starting syslog-ng daemon"
syslog-ng -F --cfgfile=$SYSLOG_CONF --pidfile /run/syslog-ng.pid --no-caps

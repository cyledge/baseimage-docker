#!/bin/bash
set -e
. /usr/local/share/cyledge/bash-library

# If /dev/log is either a named pipe or it was placed there accidentally,
# e.g. because of the issue documented at https://github.com/phusion/baseimage-docker/pull/25,
# then we remove it.
if [ ! -S /dev/log ]; then rm -f /dev/log; fi
if [ ! -S /var/lib/syslog-ng/syslog-ng.ctl ]; then rm -f /var/lib/syslog-ng/syslog-ng.ctl; fi



status "starting syslog-ng daemon"

exec syslog-ng --foreground --cfgfile=$SYSLOG_CONF --pidfile /run/syslog-ng.pid --no-caps

#
# TODO: start syslog-ng as user syslog. Currently permission issues on creation of /dev/log prevents this...

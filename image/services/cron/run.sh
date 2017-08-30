#!/bin/sh
. /usr/local/share/cyLEDGE/bash-library

status "starting cron daemon"
exec /usr/sbin/cron -f

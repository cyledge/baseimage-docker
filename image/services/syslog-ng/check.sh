#!/bin/bash

set -e
. /usr/local/share/cyledge/bash-library


# Set (default) target host for syslog
if [ -z "$FLUENT_HOST" ]; then
  set_container_env FLUENT_HOST docker-host
fi
if [ -z "$FLUENT_SYSLOG_PORT" ]; then
  set_container_env FLUENT_SYSLOG_PORT 5141
fi


if [ -z "$SYSLOG_CONF" ]; then

  set_container_env SYSLOG_CONF /etc/syslog-ng/syslog-ng.conf

  LOG_TO=${LOG_TO:-"stdout"}

  case $LOG_TO in
    "stdout")
      status "syslog is logging to stdout."
      echo "@include \"conf-stdout.d/*.conf\"" >> $SYSLOG_CONF
      ;;
    "fluent")
      if [ -z "$DOCKER_HOST_NAME" ]; then
        set_container_env DOCKER_HOST_NAME $(hostname)
        #error "logging to fluent requires env variable \"DOCKER_HOST_NAME\" to be set."
        #exit 1
      fi
      status "syslog is logging to fluent host $FLUENT_HOST."
      echo "@include \"conf-fluent.d/*.conf\"" >> $SYSLOG_CONF
      ;;
    *)
      error "Invalid LOG_TO value: $LOG_TO"
      exit 1
      ;;
  esac

else

  status "Using custom syslog-ng config file: $SYSLOG_CONF"

fi




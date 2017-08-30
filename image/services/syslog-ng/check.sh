#!/bin/bash

set -e
. /usr/local/share/cyLEDGE/bash-library

. /etc/os-release

if [ "$VERSION_ID" == "12.04" ]; then
  status "concatinating syslog-ng conf files from /etc/syslog-ng/conf.d/*.conf to work around bug in current syslog-ng version..."
  
  cat /etc/syslog-ng/conf.d/*.conf > /tmp/syslog-ng-include.conf
  
  cp /etc/syslog-ng/syslog-ng.conf /tmp/syslog-ng.conf
  sed -i 's/@include "conf\.d\/\*\.conf"/@include "\/tmp\/syslog-ng-include\.conf"/g' /tmp/syslog-ng.conf
  
  export SYSLOG_CONF=/tmp/syslog-ng.conf
else
  export SYSLOG_CONF=/etc/syslog-ng/syslog-ng.conf
fi

 

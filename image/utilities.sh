#!/bin/bash
set -e
. /build/buildconfig
. /build/bash-library


status "Adding container utlities..."

## Add THE "bash library" into the system
mkdir /usr/local/share/cyLEDGE
cp /build/bash-library /usr/local/share/cyLEDGE/bash-library


## Switch default shell to bash
ln -sf /bin/bash /bin/sh


## This tool runs a command as another user and sets $HOME.
cp /build/bin/setuser /sbin/setuser


## Add the host ip detector as startup script
cp /build/bin/detect-docker-host-ip /etc/my_init.d/


#!/bin/bash
set -e

function abort()
{
	echo "$@"
	exit 1
}

function cleanup()
{
  if [ -n "$ID" ]; then
    echo " --> Stopping container"
    docker stop -t=10 $ID &>/dev/null
    echo " --> Destroying container"
    docker rm $ID >/dev/null
  fi
}

NAME=${NAME:-cyledge/base}
VERSION=${VERSION:-latest}
PWD=`pwd`
STARTUP_DELAY=${STARTUP_DELAY:-5}

trap cleanup EXIT

echo " --> Starting container"
ID=`docker run -d -v $PWD/test:/test $NAME:$VERSION /sbin/my_init`
echo " --> Waiting $STARTUP_DELAY sec. to let to container start up it's services"
sleep $STARTUP_DELAY

echo " --> Test if container is running"
docker inspect $ID &> /dev/null
status=$?
if [ "$status" != "0" ]; then
  abort "FAIL"
fi

echo " --> Testing if all defined services are running in container"
docker exec $ID /bin/bash -c /test/test.sh

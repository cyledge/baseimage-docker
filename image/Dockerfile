FROM ubuntu:18.04
MAINTAINER CYLEDGE <dev@cyledge.com>

ADD . /build

ENV DEBIAN_FRONTEND="noninteractive" \
    INITRD="no"

RUN /build/bootstrap-base-image.sh

CMD ["/sbin/my_init"]

ONBUILD ARG LOCALE="en_US.UTF-8"
ONBUILD ARG LANGUAGE="en_US:en"
ONBUILD ARG TZ="Europe/Vienna"
    
ONBUILD ARG IMAGE_BUILD_DEBUG=0


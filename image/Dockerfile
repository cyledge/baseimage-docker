FROM ubuntu:16.04
MAINTAINER cyLEDGE <dev@cyledge.com>

ADD . /build

ENV DEBIAN_FRONTEND="noninteractive" \
    INITRD="no"

RUN /build/bootstrap-base-image.sh

ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8"

CMD ["/sbin/my_init"]

ONBUILD ARG IMAGE_BUILD_DEBUG=0
ONBUILD ENV IMAGE_BUILD_DEBUG ${IMAGE_BUILD_DEBUG}


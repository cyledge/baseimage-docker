ARG UBUNTU_VERSION="20.04"
FROM ubuntu:$UBUNTU_VERSION

LABEL maintainer="CYLEDGE Development"
LABEL repository="https://gitlab.com/cyledge/images"

ADD . /build

ENV DEBIAN_FRONTEND="noninteractive" \
    INITRD="no"

RUN /build/bootstrap-base-image.sh

CMD ["/sbin/my_init"]

ONBUILD ARG LOCALE="en_US.UTF-8"
ONBUILD ARG LANGUAGE="en_US:en"
ONBUILD ARG TZ="Europe/Vienna"
    
ONBUILD ARG IMAGE_BUILD_DEBUG=0


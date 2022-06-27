ARG UBUNTU_VERSION="20.04"
FROM ubuntu:$UBUNTU_VERSION

LABEL maintainer="CYLEDGE Development"
LABEL repository="https://gitlab.com/cyledge/image/base"

ARG DEBIAN_FRONTEND="noninteractive" \
    INITRD="no" \
    DEBCONF_NOWARNINGS="yes" \
    LANG="C.UTF-8"

ENV LANGUAGE="en_US:en" \
    TZ="Europe/Vienna"

RUN echo "debconf debconf/frontend select ${DEBIAN_FRONTEND}" | debconf-set-selections \
 && echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99install-recommends \
 && echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/99assume-yes

ADD . /build

RUN /build/bootstrap-base-image.sh

CMD ["/sbin/my_init"]

ONBUILD ARG LOCALE="en_US.UTF-8" \
            IMAGE_BUILD_DEBUG=0

ONBUILD RUN /build/prepare.sh

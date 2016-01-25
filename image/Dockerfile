FROM ubuntu:14.04
MAINTAINER cyLEDGE <dev@cyledge.com>

ADD . /build

RUN /build/prepare.sh &&\
 /build/system_services.sh &&\
 /build/utilities.sh

# Set (default) target host for syslog
ENV FLUENT_HOST docker-host
ENV FLUENT_SYSLOG_PORT 5141
	
CMD ["/sbin/my_init"]

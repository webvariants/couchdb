FROM debian:latest
MAINTAINER Robert Newson <rnewson@apache.org>
ENV DEBIAN_FRONTEND noninteractive

# Install prereqs
RUN echo "deb http://http.debian.net/debian wheezy-backports main" >> /etc/apt/sources.list
RUN apt-get -qq update
RUN apt-get -y install build-essential git libmozjs185-dev libicu-dev erlang-nox erlang-dev python wget

# Set up user for the builds
RUN useradd -m couchdb

# Build rebar
USER couchdb
WORKDIR /home/couchdb

RUN wget https://github.com/rebar/rebar/archive/2.5.0.tar.gz
RUN tar xzf 2.5.0.tar.gz
WORKDIR /home/couchdb/rebar-2.5.0
RUN ./bootstrap
USER root
RUN cp rebar /usr/local/bin/

# Build couchdb
USER couchdb
WORKDIR /home/couchdb

RUN git clone https://git-wip-us.apache.org/repos/asf/couchdb.git
WORKDIR /home/couchdb/couchdb

# We don't to be so strict for simple testing.
RUN sed -i'' '/require_otp_vsn/d' rebar.config.script

# Expose nodes on external network interface
RUN sed -i'' 's/bind_address = 127.0.0.1/bind_address = 0.0.0.0/' rel/overlay/etc/default.ini

# Build
RUN ./configure
RUN make

EXPOSE 15984 25984 35984 15986 25986 35986
ENTRYPOINT ["/home/couchdb/couchdb/dev/run"]

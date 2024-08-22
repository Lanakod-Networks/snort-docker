FROM ubuntu:22.04 AS builder
ARG DEBIAN_FRONTEND=noninteractive

ENV PREFIX_DIR=/usr/local
ENV HOME=/root

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install \
  wget git cmake make g++ bison flex cppcheck cpputest autoconf automake libtool curl gdb vim build-essential luajit hwloc openssl pkg-config \
  strace perl libio-socket-ssl-perl libcrypt-ssleay-perl ca-certificates libwww-perl supervisor net-tools iputils-ping iproute2 ethtool \
  libdumbnet-dev libdnet-dev libpcap-dev libtirpc-dev libmnl-dev libunwind-dev libpcre3-dev zlib1g-dev libnet1-dev liblzma-dev \
  libssl-dev libhwloc-dev libsqlite3-dev uuid-dev libcmocka-dev libnetfilter-queue-dev autotools-dev libluajit-5.1-dev libfl-dev \
  libpcre3 libpcre3-dbg libyaml-0-2 libyaml-dev zlib1g libcap-ng-dev libcap-ng0 libmagic-dev libnuma-dev

# Build libdaq
WORKDIR $HOME
RUN git clone https://github.com/snort3/libdaq.git && \
  cd libdaq && ./bootstrap && ./configure --prefix=${PREFIX_DIR} && make && make install

# Build gperftools
WORKDIR $HOME
RUN wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz && tar xzf gperftools-2.9.1.tar.gz && \
  cd gperftools-2.9.1 && ./configure && make && make install

# Build snort
WORKDIR $HOME
RUN wget https://github.com/snort3/snort3/archive/refs/tags/3.3.2.0.tar.gz && tar xzf 3.3.2.0.tar.gz && \
  cd snort3-3.3.2.0 && ./configure_cmake.sh --prefix=${PREFIX_DIR} --enable-tcmalloc --disable-docs && \
  cd build && make && make install && \
  ln -s /usr/local/lib/libtcmalloc.so.4 /lib/ && \
  ln -s /usr/local/lib/libdaq.so.3 /lib/ && \
  ldconfig

# Add community rules to snort
WORKDIR $HOME
RUN mkdir ${PREFIX_DIR}/etc/rules && \
  mkdir ${PREFIX_DIR}/etc/so_rules/ && \
  mkdir ${PREFIX_DIR}/etc/lists/ && \
  touch ${PREFIX_DIR}/etc/rules/local.rules && \
  touch ${PREFIX_DIR}/etc/lists/default.blocklist && \
  mkdir /var/log/snort
COPY ./tars/snort3-community-rules.tar.gz ${HOME}/snort3-community-rules.tar.gz
COPY ./tars/feodotracker.tar.gz ${HOME}/feodotracker.tar.gz
COPY ./tars/appid-rules.tar.gz ${HOME}/appid-rules.tar.gz
COPY ./tars/emerging-rules.tar.gz ${HOME}/emerging-rules.tar.gz
RUN tar -xvzf snort3-community-rules.tar.gz && cd snort3-community-rules && mkdir ${PREFIX_DIR}/etc/rules/snort3-community-rules/ && cp * ${PREFIX_DIR}/etc/rules/snort3-community-rules/

WORKDIR $HOME
RUN tar -xvzf feodotracker.tar.gz && ls && cd feodotracker && mkdir ${PREFIX_DIR}/etc/rules/feodotracker/ && cp * ${PREFIX_DIR}/etc/rules/feodotracker/

WORKDIR $HOME
RUN tar -xvzf appid-rules.tar.gz && cd appid-rules && mkdir ${PREFIX_DIR}/etc/rules/appid-rules/ && cp * ${PREFIX_DIR}/etc/rules/appid-rules/

WORKDIR $HOME
RUN tar -xvzf emerging-rules.tar.gz && cd emerging-rules && mkdir ${PREFIX_DIR}/etc/rules/emerging-rules/ && cp * ${PREFIX_DIR}/etc/rules/emerging-rules/

RUN snort --version

# Install OpenAppID
WORKDIR $HOME
COPY ./tars/snort-openappid.tar.gz ${HOME}/OpenAppId-23020.tar.gz
RUN tar -xzvf OpenAppId-23020.tar.gz && mkdir -p /usr/local/lib/openappid && cp -r odp /usr/local/lib/openappid

WORKDIR $HOME
COPY ./scripts/healthcheck.sh ${HOME}/healthcheck.sh
RUN chmod +x ${HOME}/healthcheck.sh
HEALTHCHECK --interval=30s CMD ${HOME}/healthcheck.sh

COPY ./configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./scripts/entrypoint.sh ${HOME}/entrypoint.sh

ENTRYPOINT ["/bin/bash", "/root/entrypoint.sh"]
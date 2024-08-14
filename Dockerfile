FROM ubuntu:22.04 AS builder
ARG DEBIAN_FRONTEND=noninteractive

ENV PREFIX_DIR=/usr/local
ENV HOME=/root

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install \
  wget git cmake make g++ bison flex cppcheck cpputest autoconf automake libtool curl gdb vim build-essential luajit hwloc openssl pkg-config openssh-server \
  strace perl libio-socket-ssl-perl libcrypt-ssleay-perl ca-certificates libwww-perl python3-pip python3-pcapy python3-dpkt supervisor net-tools iputils-ping python3 \
  libdumbnet-dev libdnet-dev libpcap-dev libtirpc-dev libmnl-dev libunwind-dev libpcre3-dev zlib1g-dev libnet1-dev liblzma-dev \
  libssl-dev libhwloc-dev libsqlite3-dev uuid-dev libcmocka-dev libnetfilter-queue-dev autotools-dev libluajit-5.1-dev libfl-dev \
  libpcre3 libpcre3-dbg libyaml-0-2 libyaml-dev zlib1g libcap-ng-dev libcap-ng0 libmagic-dev libnuma-dev

# Build libdaq
WORKDIR $HOME
RUN git clone https://github.com/snort3/libdaq.git
WORKDIR $HOME/libdaq
RUN ./bootstrap && ./configure --prefix=${PREFIX_DIR} && make && make install

# Build gperftools
WORKDIR $HOME
RUN wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz && tar xzf gperftools-2.9.1.tar.gz

WORKDIR $HOME/gperftools-2.9.1
RUN ./configure && make && make install

# Build snort
WORKDIR $HOME
RUN wget https://github.com/snort3/snort3/archive/refs/tags/3.3.2.0.tar.gz && tar xzf 3.3.2.0.tar.gz
WORKDIR $HOME/snort3-3.3.2.0
RUN ./configure_cmake.sh --prefix=${PREFIX_DIR} --enable-tcmalloc --disable-docs
WORKDIR $HOME/snort3-3.3.2.0/build
RUN make && make install
RUN ln -s /usr/local/lib/libtcmalloc.so.4 /lib/ && \
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
COPY snort3-community-rules.tar ${HOME}/snort3-community-rules.tar
RUN tar -xvzf snort3-community-rules.tar && cd snort3-community-rules && cp * ${PREFIX_DIR}/etc/rules/
RUN snort --version

# Install OpenAppID
WORKDIR $HOME
COPY snort-openappid.tar.gz ${HOME}/OpenAppId-23020.tar.gz
RUN tar -xzvf OpenAppId-23020.tar.gz && cp -R odp /usr/local/lib/

RUN pip3 install pygeoip dnif idstools
#RUN mkdir /usr/local/lookups && cd /usr/local/lookups && \
#    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && \
#    wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz && \
#    gunzip GeoLiteCity.dat.gz GeoIPASNum.dat.gz

# Install snort-sgent
WORKDIR /usr/local/src
RUN wget https://github.com/dnif/snort-agent/archive/0.8.tar.gz && tar -zxvf 0.8.tar.gz && mv snort-agent-* snort-agent

# Set up SSH
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh ${HOME}/entrypoint.sh
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

#ENTRYPOINT ["snort", "-c", "/usr/local/etc/snort/snort.lua", "-R", "/usr/local/etc/rules/snort3-community.rules", "-i", "wl01", "-s", "65535", "-k", "none"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["/bin/bash", "/root/entrypoint.sh"]
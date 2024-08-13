#
# BUILD CONTAINER
# (Note that this is a multi-phase Dockerfile)
# To build run `docker build --rm -t tebedwel/snort3-alpine:latest`
#
FROM ubuntu:22.04 AS builder

ENV PREFIX_DIR=/usr/local
ENV HOME=/root

# Update apt-get adding the @testing repo for hwloc (as of Alpine v3.7)
# RUN apt-get add -X https://dl-cdn.alpinelinux.org/alpine/v3.16/main -u alpine-keys
# RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apt-get/repositories

# Prep apt-get for installing packages
RUN apt-get update -y && apt-get upgrade -y

# BUILD DEPENDENCIES:
RUN apt-get install -y \
  wget \
  git \
  cmake \
  make \
  g++ \
  bison \
  flex \
  cppcheck \
  cpputest \
  autoconf \
  automake \
  libtool \
  # Libraries
  libdumbnet-dev \
  libdnet-dev \
  libpcap-dev \
  libtirpc-dev \
  libmnl-dev \
  libunwind-dev \
# Install the Snort developer requirements
  curl \
  gdb \
  vim \
  build-essential \
  libpcre3-dev \
  libnet1-dev \
  zlib1g-dev \
  luajit \
  hwloc \
  liblzma-dev \
  openssl \
  libssl-dev \
  pkg-config \
  libhwloc-dev \
  libsqlite3-dev \
  uuid-dev \
  libcmocka-dev \
  libnetfilter-queue-dev \
  autotools-dev \
  libluajit-5.1-dev \
  libfl-dev

# One of the quirks of alpine is that unistd.h is in /usr/include. Lots of
# software looks for it in /usr/include/linux or /usr/include/sys.
# So, we'll make symlinks
# RUN mkdir /usr/include/linux && \
#     ln -s /usr/include/unistd.h /usr/include/linux/unistd.h && \
#     ln -s /usr/include/unistd.h /usr/include/sys/unistd.h

# The Alpine hwloc on testing is not reliable from a build perspective.
# So, lets just build it ourselves.
#
#WORKDIR $HOME
#RUN wget https://download.open-mpi.org/release/hwloc/v2.0/hwloc-2.0.3.tar.gz &&\
#    tar zxvf hwloc-2.0.3.tar.gz
#WORKDIR $HOME/hwloc-2.0.3
#RUN ./configure --prefix=${PREFIX_DIR} && \
#    make && \
#    make install

# BUILD Daq on alpine:

WORKDIR $HOME
RUN git clone https://github.com/snort3/libdaq.git
WORKDIR $HOME/libdaq
RUN ./bootstrap && \
  ./configure --prefix=${PREFIX_DIR} && make && \
  make install
    
# BUILD gperftools

WORKDIR $HOME
RUN wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz &&\
  tar xzf gperftools-2.9.1.tar.gz

WORKDIR $HOME/gperftools-2.9.1
RUN ./configure && make && make install


# BUILD Snort on alpine
WORKDIR $HOME
# RUN git clone https://github.com/snort3/snort3.git
RUN wget https://github.com/snort3/snort3/archive/refs/tags/3.3.2.0.tar.gz &&\
  tar xzf 3.3.2.0.tar.gz

WORKDIR $HOME/snort3-3.3.2.0
RUN ./configure_cmake.sh \
  --prefix=${PREFIX_DIR} \
  --enable-tcmalloc \
  --disable-docs
  
WORKDIR $HOME/snort3-3.3.2.0/build
RUN make && make install
RUN ln -s /usr/local/lib/libtcmalloc.so.4 /lib/ && \
  ln -s /usr/local/lib/libdaq.so.3 /lib/ && \
  ldconfig
  

#
# RUNTIME CONTAINER
#
#FROM ubuntu:22.04

#ENV PREFIX_DIR=/usr/local
#WORKDIR ${PREFIX_DIR}

# Prep apt-get for installing packages
#RUN apt-get update -y
#RUN apt-get upgrade -y

# RUNTIME DEPENDENCIES:
#RUN apt-get install \
#    libdnet \
#    luajit \
#    musl \
#    libstdc++

# Copy the build artifacts from the build container to the runtime file system
#COPY --from=builder ${PREFIX_DIR}/etc/ /etc/
#COPY --from=builder ${PREFIX_DIR}/lib/ /lib/
#COPY --from=builder ${PREFIX_DIR}/lib64/ ${PREFIX_DIR}/lib64/
#COPY --from=builder ${PREFIX_DIR}/bin/ /bin/

WORKDIR $HOME
RUN mkdir ${PREFIX_DIR}/etc/rules && \
  mkdir ${PREFIX_DIR}/etc/so_rules/ && \
  mkdir ${PREFIX_DIR}/etc/lists/ && \
  touch ${PREFIX_DIR}/etc/rules/local.rules && \
  touch ${PREFIX_DIR}/etc/lists/default.blocklist && \
  mkdir /var/log/snort

COPY snort3-community-rules.tar ${HOME}/snort3-community-rules.tar

RUN tar -xvzf snort3-community-rules.tar && \
  cd snort3-community-rules && \
  cp * ${PREFIX_DIR}/etc/rules/

RUN snort --version

ENTRYPOINT ["snort", "-c", "/usr/local/etc/snort/snort.lua", "-R", "/usr/local/etc/rules/snort3-community.rules", "-i", "wl01", "-s", "65535", "-k", "none"]

#ENTRYPOINT ["tail", "-f", "/dev/null"]
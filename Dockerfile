FROM alpine:latest

LABEL maintainer='HuangYeWuDeng <***@ttys0.in>'

# Install required packages
RUN  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
   && apk add --update --no-cache \
        boost-system \
        boost-thread \
        ca-certificates \
        dumb-init \
        openssl \
        qt5-qtbase

# Compiling qBitTorrent following instructions on
# https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#Libtorrent
RUN set -x \
 && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    # Install build dependencies
 && apk add --update --no-cache -t .build-deps \
        boost-dev \
        curl \
        cmake \
        g++ \
        make \
        openssl-dev \
    # Build lib rasterbar from source code (required by qBittorrent)
    # Until https://github.com/qbittorrent/qBittorrent/issues/6132 is fixed, need to use version 1.0.*
 && LIBTORRENT_RASTERBAR_URL="https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_1_13/libtorrent-rasterbar-1.1.13.tar.gz" \
 && mkdir /tmp/libtorrent-rasterbar \
 && curl -sSL $LIBTORRENT_RASTERBAR_URL | tar xzC /tmp/libtorrent-rasterbar \
 && cd /tmp/libtorrent-rasterbar/* \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=11 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_INSTALL_LIBDIR=lib .. \
 && make -j $((`nproc --all`+1)) install \
    # Clean-up
 && cd / \
 && apk del --purge .build-deps \
 && rm -rf /tmp/*

RUN set -x \
 && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    # Install build dependencies
 && apk add --update --no-cache -t .build-deps \
        boost-dev \
        g++ \
        git \
        make \
        openssl-dev \
        qt5-qttools-dev \
    # Build qBittorrent from source code
 && git clone https://github.com/qbittorrent/qBittorrent.git /tmp/qbittorrent \
 && git clone http://172.17.0.1:8086/ /tmp/qbittorrent-patches \
 && cd /tmp/qbittorrent \
    # Checkout latest release
 && latesttag=$(git describe --tags `git rev-list --tags --max-count=1`) \
 && git checkout $latesttag \
    # patch
 && for p in `ls -1 /tmp/qbittorrent-patches/*.patch`; \
        do patch -N --no-backup-if-mismatch -p1 < $p; done \
    # Compile
 && PKG_CONFIG_PATH=/usr/lib/pkgconfig ./configure --prefix=/usr --disable-gui --disable-stacktrace \
 && make -j $((`nproc --all`+1)) install \
    # Clean-up
 && cd / \
 && apk del --purge .build-deps \
 && rm -rf /tmp/* \
    # Add non-root user
 && adduser -S -D -u 520 -g 520 -s /sbin/nologin qbittorrent \
    # Create symbolic links to simplify mounting
 && mkdir -p /home/qbittorrent/.config/qBittorrent \
 && mkdir -p /home/qbittorrent/.local/share/data/qBittorrent \
 && mkdir /downloads \
 && chmod go+rw -R /home/qbittorrent /downloads \
 && ln -s /home/qbittorrent/.config/qBittorrent /config \
 && ln -s /home/qbittorrent/.local/share/data/qBittorrent /torrents \
    # Check it works
 && su qbittorrent -s /bin/sh -c 'qbittorrent-nox -v'

# Default configuration file.
COPY qBittorrent.conf /default/qBittorrent.conf
COPY entrypoint.sh /

VOLUME ["/config", "/torrents", "/downloads"]

ENV HOME=/home/qbittorrent \
WEB_PORT=8080 \
BT_PORT=8999 \
QBT_AUTH_SERVER_ADDR=172.17.0.1

USER qbittorrent

EXPOSE $WEB_PORT $BT_PORT

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]
CMD ["qbittorrent-nox"]

# vim: set ft=dockerfile ts=4 sw=4 et:
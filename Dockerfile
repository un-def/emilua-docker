ARG IMAGE_NAME
ARG VERSION
ARG BUILD_DATE

ARG BASE='ubuntu:24.04'


FROM ${BASE} AS base


FROM base AS builder

ARG IMAGE_NAME
ARG VERSION
ARG BUILD_DATE

WORKDIR /build/

RUN \
    : "${IMAGE_NAME:?}" && \
    : "${VERSION:?}" && \
    : "${BUILD_DATE:?}" && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        g++ \
        pkg-config \
        make \
        cmake \
        meson \
        re2c \
        gawk \
        gperf \
        asciidoctor \
        libc-dev \
        libboost-all-dev \
        libssl-dev \
        libcap-dev \
        libfmt-dev \
        libserd-dev \
        libsord-dev \
        libcereal-dev \
        libncurses-dev \
    && \
    export MULTILIB=lib/x86_64-linux-gnu && \
    # luajit build
    git clone --depth 1 --branch v2.1 https://github.com/LuaJIT/LuaJIT && \
    cd LuaJIT && \
    make PREFIX=$(pwd)/prefix MULTILIB=${MULTILIB} CFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT && \
    make PREFIX=$(pwd)/prefix MULTILIB=${MULTILIB} install && \
    export PKG_CONFIG_PATH=$(pwd)/prefix/${MULTILIB}/pkgconfig && \
    cd .. && \
    # emilua build
    git clone --depth 1 --branch "v${VERSION}" https://gitlab.com/emilua/emilua.git && \
    cd emilua && \
    meson setup --prefix=$(pwd)/prefix --libdir=${MULTILIB} build && \
    meson compile -C build && \
    meson install -C build && \
    cd .. && \
    # fix pc files
    sed -i 's|prefix=.*|prefix=/usr/local|' LuaJIT/prefix/${MULTILIB}/pkgconfig/luajit.pc && \
    sed -i 's|prefix=.*|prefix=/usr/local|' emilua/prefix/${MULTILIB}/pkgconfig/emilua.pc


FROM base

ARG IMAGE_NAME
ARG VERSION
ARG BUILD_DATE

COPY --from=builder /build/LuaJIT/prefix/ /build/emilua/prefix/ /usr/local/

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libboost-context1.83.0 \
        libfmt9 \
        libserd-0-0 \
        libsord-0-0 \
    && \
    ldconfig

LABEL name="Emilua"
LABEL image-name="${IMAGE_NAME}"
LABEL maintainer="Dmitry Meyer <me@undef.im>"
LABEL version="${VERSION}"
LABEL build-date="${BUILD_DATE}"

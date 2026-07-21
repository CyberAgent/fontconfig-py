#!/usr/bin/env bash

set -ex

build_freetype() {
    cd third_party/freetype
    ./autogen.sh
    ./configure \
        --disable-shared \
        --with-pic \
        --without-bzip2 \
        --without-png \
        --without-harfbuzz \
        --without-brotli \
        --without-librsvg
    make -j
    make install
    cd ../..
}

build_fontconfig() {
    cd third_party/fontconfig
    ./autogen.sh \
        --sysconfdir=${FC_SYSCONFDIR:-"/etc"} \
        --localstatedir=${FC_LOCALSTATEDIR:-"/var"} \
        --disable-shared \
        --with-pic \
        --disable-libxml2 \
        --disable-iconv \
        --disable-docs \
        --disable-cache-build
    make -j
    make install
    cd ../..
}

prepare_macos_dirs() {
    # Fix permissions for macOS runners.
    sudo mkdir -p \
        /usr/local/bin \
        /usr/local/lib \
        /usr/local/include \
        /usr/local/share \
        /usr/local/var \
        /usr/local/etc && \
        sudo chown -R $(whoami) /usr/local/*
}

# Install build dependencies
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew is required for macOS builds" >&2
        echo "Install Homebrew from https://brew.sh" >&2
        exit 1
    fi

    export CFLAGS="$CFLAGS -arch x86_64 -arch arm64"
    export LDFLAGS="$LDFLAGS -arch x86_64 -arch arm64"
    export LIBTOOLIZE="glibtoolize"
    # Set Homebrew-specific directories for fontconfig by default on macOS
    export FC_SYSCONFDIR="$(brew --prefix)/etc"
    export FC_LOCALSTATEDIR="$(brew --prefix)/var"
    # Make sure conflicting packages are not installed.
    # json-c is uninstalled too: when present, fontconfig's configure detects it
    # and builds test/test-conf, but Homebrew ships json-c arm64-only, so the
    # x86_64 slice of the universal2 build fails to link. We only need the
    # static library, not fontconfig's test suite.
    brew uninstall --ignore-dependencies -f fontconfig freetype json-c
    brew install gperftools gettext automake libtool
    prepare_macos_dirs
elif command -v dnf &> /dev/null; then
    dnf install -y gperf gettext-devel libuuid-devel
elif command -v yum &> /dev/null; then
    yum --disablerepo=epel install -y gperf gettext-devel libuuid-devel
elif command -v apk &> /dev/null; then
    apk add gperf gettext-dev util-linux-dev
elif command -v apt &> /dev/null; then
    apt -y install gperf gettext uuid-dev
else
    exit 1
fi

build_freetype
build_fontconfig

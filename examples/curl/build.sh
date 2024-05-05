#!/usr/bin/env bash

set -e

[ ! -d curl ] && git clone --depth=1 https://github.com/curl/curl.git

[ -d build ] && rm -rf build

SDK_SYSROOT=$(xcrun --sdk macosx --show-sdk-path)

cmake -S curl -B build -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(pwd)/../../xcrun.toolchain.cmake \
        -DCMAKE_OSX_TRIPLE_OS=macosx \
        -DCMAKE_OSX_TRIPLE_OS_VERSION=10.9 \
        -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
        -DBUILD_SHARED_LIBS=OFF \
        -DCURL_USE_SECTRANSP=ON \
        -DCURL_DEFAULT_SSL_BACKEND=secure-transport \
        -DENABLE_IPV6=ON \
        -DCURL_USE_LIBPSL=OFF \
        -DCURL_DISABLE_LDAP=ON \
        -DZLIB_INCLUDE_DIR=${SDK_SYSROOT}/usr/include \
        -DZLIB_LIBRARY=${SDK_SYSROOT}/usr/lib/libz.tbd

ninja -C build

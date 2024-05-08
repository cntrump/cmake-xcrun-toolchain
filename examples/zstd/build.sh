#!/usr/bin/env bash

set -e

[ ! -d zstd ] && git clone -b v1.5.6 https://github.com/facebook/zstd.git

[ -d build ] && rm -rf build

cmake -S zstd/build/cmake -B build -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(pwd)/../../xcrun.toolchain.cmake \
        -DCMAKE_OSX_TRIPLE_OS=macosx \
        -DCMAKE_OSX_TRIPLE_OS_VERSION=10.9 \
        -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
        -DCMAKE_CLANG_ENABLE_MODULES=OFF

ninja -C build
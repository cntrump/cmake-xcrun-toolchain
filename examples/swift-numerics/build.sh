#!/usr/bin/env bash

set -eux

[ ! -d swift-numerics ] && \
git clone --depth=1 https://github.com/apple/swift-numerics.git

toolchain=$(pwd)/../../xcrun.toolchain.cmake

common_flags=(
    "-S swift-numerics"
    "-B build"
    "-G Ninja"
    "-DCMAKE_TOOLCHAIN_FILE=${toolchain}"
    "-DBUILD_TESTING=NO"
)

macosx_flags=(
    "-DCMAKE_OSX_TRIPLE_OS=macosx"
    "-DCMAKE_OSX_TRIPLE_OS_VERSION=10.9"
    "-DCMAKE_INSTALL_PREFIX=$(pwd)/_install/macosx"
    "-DCMAKE_OSX_ARCHITECTURES=arm64"
)

[ -d build ] && rm -rf build
[ -d _install ] && rm -rf _install
cmake ${common_flags[*]} ${macosx_flags[*]}
ninja -C build install

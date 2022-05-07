#!/usr/bin/env bash

set -eux

[ ! -d cppinsights ] && \
git clone --depth=1 https://github.com/andreasfertig/cppinsights.git

toolchain=$(pwd)/../../xcrun.toolchain.cmake

common_flags=(
    "-S cppinsights"
    "-B build"
    "-G Ninja"
    "-DCMAKE_TOOLCHAIN_FILE=${toolchain}"
    "-DLLVM_CONFIG_PATH=llvm-config"
    "-DINSIGHTS_STATIC=OFF"
    "-DINSIGHTS_USE_LIBCPP=ON"
    "-DDEBUG=OFF"
)

macosx_flags=(
    "-DCMAKE_OSX_TRIPLE_OS=macosx"
    "-DCMAKE_OSX_TRIPLE_OS_VERSION=10.13"
    "-DCMAKE_INSTALL_PREFIX=$(pwd)/_install/macosx"
    "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64"
)

[ -d build ] && rm -rf build
[ -d _install ] && rm -rf _install
cmake ${common_flags[*]} ${macosx_flags[*]}
ninja -C build install

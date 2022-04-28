#!/usr/bin/env bash

set -eux

[ ! -d boringssl ] && \
git clone --depth=1 https://boringssl.googlesource.com/boringssl

toolchain=$(pwd)/../../xcrun.toolchain.cmake

common_flags=(
    "-S boringssl"
    "-B build"
    "-G Ninja"
    "-DCMAKE_TOOLCHAIN_FILE=${toolchain}"
    "-DOPENSSL_SMALL=1"
    "-DOPENSSL_NO_ASM=1"
)

macosx_flags=(
    "-DCMAKE_OSX_TRIPLE_OS=macosx"
    "-DCMAKE_OSX_TRIPLE_OS_VERSION=10.13"
    "-DCMAKE_INSTALL_PREFIX=$(pwd)/_install/macosx"
)

ios_flags=(
    "-DCMAKE_OSX_TRIPLE_OS=ios"
    "-DCMAKE_OSX_TRIPLE_OS_VERSION=13.0"
    "-DCMAKE_INSTALL_PREFIX=$(pwd)/_install/ios"
)

iossim_flags=(
    "-DCMAKE_OSX_TRIPLE_OS=ios"
    "-DCMAKE_OSX_TRIPLE_ENVIRONMENT=simulator"
    "-DCMAKE_OSX_TRIPLE_OS_VERSION=13.0"
    "-DCMAKE_INSTALL_PREFIX=$(pwd)/_install/iossim"
)

maccatalyst_flags=(
    "-DCMAKE_OSX_TRIPLE_OS=ios"
    "-DCMAKE_OSX_TRIPLE_ENVIRONMENT=macabi"
    "-DCMAKE_OSX_TRIPLE_OS_VERSION=13.1"
    "-DCMAKE_INSTALL_PREFIX=$(pwd)/_install/maccatalyst"
)

tvos_flags=(
    "-DCMAKE_OSX_TRIPLE_OS=tvos"
    "-DCMAKE_OSX_TRIPLE_OS_VERSION=10.0"
    "-DCMAKE_INSTALL_PREFIX=$(pwd)/_install/tvos"
)

tvossim_flags=(
    "-DCMAKE_OSX_TRIPLE_OS=tvos"
    "-DCMAKE_OSX_TRIPLE_ENVIRONMENT=simulator"
    "-DCMAKE_OSX_TRIPLE_OS_VERSION=10.0"
    "-DCMAKE_INSTALL_PREFIX=$(pwd)/_install/tvossim"
)

[ -d build ] && rm -rf build
[ -d _install ] && rm -rf _install
cmake ${common_flags[*]} ${macosx_flags[*]}
ninja -C build install

[ -d build ] && rm -rf build
[ -d _install ] && rm -rf _install
cmake ${common_flags[*]} ${ios_flags[*]}
ninja -C build install

[ -d build ] && rm -rf build
[ -d _install ] && rm -rf _install
cmake ${common_flags[*]} ${iossim_flags[*]}
ninja -C build install

[ -d build ] && rm -rf build
[ -d _install ] && rm -rf _install
cmake ${common_flags[*]} ${maccatalyst_flags[*]}
ninja -C build install

[ -d build ] && rm -rf build
[ -d _install ] && rm -rf _install
cmake ${common_flags[*]} ${tvos_flags[*]}
ninja -C build install

[ -d build ] && rm -rf build
[ -d _install ] && rm -rf _install
cmake ${common_flags[*]} ${tvossim_flags[*]}
ninja -C build install

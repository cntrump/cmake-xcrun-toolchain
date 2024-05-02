# CMake XCRun Toolchain

A CMake toolchain file for macOS, macCatalyst, iOS, tvOS, watchOS.

Using default C standard: `gnu11`, C++ standard: `gnu++14`, Swift language version: `5.0`.

Requried Generator is [Ninja](https://github.com/ninja-build/ninja).

Don't use `CMAKE_OSX_DEPLOYMENT_TARGET` specify target platform any more.

Value of `--target ${triple}` and `CMAKE_OSX_SYSROOT` are computed based on `CMAKE_OSX_TRIPLE_*` variables.

Example:

## Build for macOS 10.13 contains `x86_64` and `arm64`:
```bash
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(pwd)/xcrun.toolchain.cmake \
      -DCMAKE_OSX_TRIPLE_OS=macosx \
      -DCMAKE_OSX_TRIPLE_OS_VERSION=10.13 \
      -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
      ...
```

## Build for macCatalyst contains `x86_64` and `arm64`:

iOSMac | macOS
-------|--------
13.1   | 10.15
13.2   | 10.15.1
13.3   | 10.15.2
13.3.1 | 10.15.3
13.4   | 10.15.4
14.0   | 11.0

```bash
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(pwd)/xcrun.toolchain.cmake \
      -DCMAKE_OSX_TRIPLE_OS=ios \
      -DCMAKE_OSX_TRIPLE_OS_VERSION=13.1 \
      -DCMAKE_OSX_TRIPLE_ENVIRONMENT=macabi \
      ...
```

## Build for iOS 10 contains `armv7` and `arm64`:
```bash
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(pwd)/xcrun.toolchain.cmake \
      -DCMAKE_OSX_TRIPLE_OS=ios \
      -DCMAKE_OSX_TRIPLE_OS_VERSION=10.0 \
      ...
```

## Build for iOS 10 Simulator only contains `x86_64` and `arm64`:
```bash
cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(pwd)/xcrun.toolchain.cmake \
      -DCMAKE_OSX_TRIPLE_OS=ios \
      -DCMAKE_OSX_TRIPLE_OS_VERSION=10.0 \
      -DCMAKE_OSX_TRIPLE_ENVIRONMENT=simulator \
      -DCMAKE_OSX_EXCLUDED_ARCHITECTURES=i386 \
      ...
```

## Build for tvOS 10 contains `armv7` and `arm64`:
```bash
CMake -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(pwd)/xcrun.toolchain.cmake \
      -DCMAKE_OSX_TRIPLE_OS=tvos \
      -DCMAKE_OSX_TRIPLE_OS_VERSION=10.0 \
      ...
```

## Build for tvOS 10 Simulator only contains `x86_64` and `arm64`:
```bash
CMake -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(pwd)/xcrun.toolchain.cmake \
      -DCMAKE_OSX_TRIPLE_OS=tvos \
      -DCMAKE_OSX_TRIPLE_OS_VERSION=10.0 \
      -DCMAKE_OSX_TRIPLE_ENVIRONMENT=simulator \
      -DCMAKE_OSX_EXCLUDED_ARCHITECTURES=i386 \
      ...
```

## Build for watchOS 2.0 contains `armv7k` and `arm64_32`:
```bash
CMake -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(pwd)/xcrun.toolchain.cmake \
      -DCMAKE_OSX_TRIPLE_OS=watchos \
      -DCMAKE_OSX_TRIPLE_OS_VERSION=2.0 \
      ...
```

## Build for watchOS 2.0 Simulator contains `i386`, `x86_64` and `arm64`:
```bash
CMake -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(pwd)/xcrun.toolchain.cmake \
      -DCMAKE_OSX_TRIPLE_OS=watchos \
      -DCMAKE_OSX_TRIPLE_OS_VERSION=10.0 \
      -DCMAKE_OSX_TRIPLE_ENVIRONMENT=simulator \
      ...
```

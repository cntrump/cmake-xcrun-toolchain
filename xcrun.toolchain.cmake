cmake_minimum_required(VERSION 3.15)  # Support Swift

#
#  Added 4 variables for specify triple for compiler:
#
#  Format of triple: ${vendor}-${os}${version}-${environment}
#  Example: apple-macosx10.9, apple-ios13.1-macabi, apple-tvos9.0-simulator
#    vendor:      `apple`.
#    os:          `macos`, `ios`, `tvos`
#    version:     `10.9`, `13.1`, `9.0`
#    emvironment: `macabi`, `simulator`
#
#  - CMAKE_OSX_TRIPLE_OS: `macosx`, `ios`, `tvos`, `watchos`
#  - CMAKE_OSX_TRIPLE_OS_VERSION: `10.9`, `9.0`, etc...
#  - CMAKE_OSX_TRIPLE_ENVIRONMENT: `macabi`, `simulator`
#  - CMAKE_OSX_EXCLUDED_ARCHITECTURES: one or more archs `i386;armv7`
#
#  Example:
#    1. build for iOS 13.0 contains armv7 and arm64:
#       CMake -DCMAKE_OSX_TRIPLE_OS=ios -DCMAKE_OSX_TRIPLE_OS_VERSION=13.0
#
#    2. build for macCatalyst contains x86_64 and arm64:
#       CMake -DCMAKE_OSX_TRIPLE_OS=ios -DCMAKE_OSX_TRIPLE_OS_VERSION=13.1 \
#             -DCMAKE_OSX_TRIPLE_ENVIRONMENT=macabi
#
#    3. build for iOS Simulator contains x86_64 and arm64:
#       CMake -DCMAKE_OSX_TRIPLE_OS=ios -DCMAKE_OSX_TRIPLE_OS_VERSION=13.0 \
#             -DCMAKE_OSX_TRIPLE_ENVIRONMENT=simulator \
#             -DCMAKE_OSX_EXCLUDED_ARCHITECTURES=i386
#

if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
  message(FATAL_ERROR "Must be run on macOS platform.")
endif()

set(CMAKE_GENERATOR Ninja)

if(NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Specifies the build type on single-configuration generators.")
endif()

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

set(CMAKE_OSX_DEPLOYMENT_TARGET "")

set(CMAKE_OSX_TRIPLE_OS macosx)
set(CMAKE_OSX_TRIPLE_ENVIRONMENT "")
set(CMAKE_OSX_EXCLUDED_ARCHITECTURES "")

set(_supported_triple_os_list
  macosx;
  ios;
  tvos;
  watchos;
  xros
)

list(FIND _supported_triple_os_list ${CMAKE_OSX_TRIPLE_OS} contains_os)
if(contains_os EQUAL -1)
  message(FATAL_ERROR "Invalid triple OS: ${CMAKE_OSX_TRIPLE_OS}.")
endif()

set(_vendor apple)
set(_triple ${_vendor}-${CMAKE_OSX_TRIPLE_OS}${CMAKE_OSX_TRIPLE_OS_VERSION})

if(CMAKE_OSX_TRIPLE_OS STREQUAL macosx)
   # macosx has not triple environment
  set(CMAKE_OSX_TRIPLE_ENVIRONMENT "")
endif()

if(NOT CMAKE_OSX_TRIPLE_ENVIRONMENT STREQUAL "")
  set(_triple ${_triple}-${CMAKE_OSX_TRIPLE_ENVIRONMENT})
endif()

if(_triple MATCHES macosx)
  set(_sdk macosx)
  set(_builtin_version_min 10.9)
endif()

if(_triple MATCHES ios)
  set(_sdk iphone)
  set(_builtin_version_min 9.0)
endif()

if(_triple MATCHES tvos)
  set(_sdk appletv)
  set(_builtin_version_min 9.0)
endif()

if(_triple MATCHES watchos)
  set(_sdk watch)
  set(_builtin_version_min 2.0)
endif()

if(_triple MATCHES xros)
  set(_sdk xros)
  set(_builtin_version_min 1.0)
endif()

if(NOT _triple MATCHES macosx)
  if(_triple MATCHES macabi)
    set(_sdk macosx)
    if(_triple MATCHES ios)
      set(_builtin_version_min 13.1)  # minimum version of ios-macabi is `13.1`
    endif()
  elseif(_triple MATCHES simulator)
    set(_sdk ${_sdk}simulator)
  else()
    set(_sdk ${_sdk}os)
  endif()
endif()

set(_supported_sdk_list
  macosx;
  iphoneos;
  iphonesimulator;
  appletvos;
  appletvsimulator;
  watchos;
  watchsimulator;
  xros;
  xrsimulator;
)

list(FIND _supported_sdk_list ${_sdk} contains_sdk)
if(contains_sdk EQUAL -1)
  message(FATAL_ERROR "Invalid SDK: ${_sdk}.")
endif()

message(STATUS "SDK: ${_sdk}")

set(CMAKE_OSX_SYSROOT ${_sdk} CACHE STRING "Specify the location or name of the Apple platform SDK to be used.")

if(NOT DEFINED CMAKE_OSX_TRIPLE_OS_VERSION)
  set(CMAKE_OSX_TRIPLE_OS_VERSION ${_builtin_version_min})
endif()

set(_triple ${_vendor}-${CMAKE_OSX_TRIPLE_OS}${CMAKE_OSX_TRIPLE_OS_VERSION})
if(NOT CMAKE_OSX_TRIPLE_ENVIRONMENT STREQUAL "")
  set(_triple ${_triple}-${CMAKE_OSX_TRIPLE_ENVIRONMENT})
endif()

set(_macosx_archs x86_64;arm64)
set(_ios_archs armv7;arm64)
set(_iossim_archs i386;x86_64;arm64)
set(_tvos_archs arm64)
set(_tvossim_archs x86_64;arm64)
set(_watchos_archs armv7k;arm64_32)
set(_watchossim_archs i386;x86_64;arm64)
set(_xros_archs arm64)
set(_xrossim_archs x86_64;arm64)

if(_sdk MATCHES macosx)
  set(_architectures ${_macosx_archs})
elseif(_sdk MATCHES iphoneos)
  set(_architectures ${_ios_archs})
elseif(_sdk MATCHES iphonesimulator)
  set(_architectures ${_iossim_archs})
elseif(_sdk MATCHES appletvos)
  set(_architectures ${_tvos_archs})
elseif(_sdk MATCHES appletvsimulator)
  set(_architectures ${_tvossim_archs})
elseif(_sdk MATCHES watchos)
  set(_architectures ${_watchos_archs})
elseif(_sdk MATCHES watchsimualtor)
  set(_architectures ${_watchossim_archs})
elseif(_sdk MATCHES xros)
  set(_architectures ${_xros_archs})
elseif(_sdk MATCHES xrsimulator)
  set(_architectures ${_xrossim_archs})
endif()

set(_archs "")
foreach(arch ${_architectures})
  list(FIND CMAKE_OSX_EXCLUDED_ARCHITECTURES ${arch} contains_arch)
  if(NOT contains_arch EQUAL -1)
    continue()
  endif()

  if(_triple MATCHES ios)  # iOS platform
    if(CMAKE_OSX_TRIPLE_OS_VERSION VERSION_GREATER_EQUAL "11")
      if((NOT arch STREQUAL arm64) AND (NOT arch STREQUAL x86_64))
        message(WARNING "Ignored ${arch} for ${_triple}, iOS 10 is the maximum deployment target for 32-bit targets.")
        continue()
      endif()
    endif()
  endif()

  list(LENGTH CMAKE_OSX_ARCHITECTURES number_of_included_archs)

  if(number_of_included_archs GREATER 0)
    list(FIND CMAKE_OSX_ARCHITECTURES ${arch} contains_arch)
    if(contains_arch EQUAL -1)
      continue()
    endif()
  endif()

  list(APPEND _archs ${arch})
endforeach()

message(STATUS "Architectures: ${_archs}")

list(LENGTH _archs number_of_archs)
if(number_of_archs EQUAL 1)
  list(GET _archs 0 triple_arch)
  set(_triple ${triple_arch}-${_triple})
endif()

message(STATUS "Triple: ${_triple}")

set(CMAKE_ASM_COMPILER_TARGET ${_triple})
set(CMAKE_C_COMPILER_TARGET ${_triple})
set(CMAKE_CXX_COMPILER_TARGET ${_triple})
set(CMAKE_Swift_COMPILER_TARGET ${_triple})

execute_process(COMMAND xcode-select -p
                OUTPUT_VARIABLE CMAKE_OSX_DEVELOPER_DIR
                OUTPUT_STRIP_TRAILING_WHITESPACE)
set(CMAKE_OSX_DEVELOPER_DIR ${CMAKE_OSX_DEVELOPER_DIR})

execute_process(COMMAND xcrun --sdk ${CMAKE_OSX_SYSROOT} --show-sdk-path
                OUTPUT_VARIABLE CMAKE_OSX_SDKROOT_DIR
                OUTPUT_STRIP_TRAILING_WHITESPACE)
set(CMAKE_OSX_SDKROOT_DIR ${CMAKE_OSX_SDKROOT_DIR})

set(ENV{DEVELOPER_DIR} ${CMAKE_OSX_DEVELOPER_DIR})
set(ENV{SDKROOT} ${CMAKE_OSX_SDKROOT_DIR})

macro(xcrun_find_program _program _variable)
  execute_process(COMMAND xcrun --find ${_program}
                  OUTPUT_VARIABLE _program_path
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(${_variable} ${_program_path})
endmacro()

xcrun_find_program(clang CMAKE_ASM_COMPILER)
xcrun_find_program(clang CMAKE_C_COMPILER)
xcrun_find_program(clang++ CMAKE_CXX_COMPILER)
xcrun_find_program(swiftc CMAKE_Swift_COMPILER)
xcrun_find_program(ld CMAKE_LINKER)
xcrun_find_program(ar CMAKE_AR)
xcrun_find_program(ranlib CMAKE_RANLIB)

set(CMAKE_C_FLAGS_INIT "")
set(CMAKE_CXX_FLAGS_INIT "")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS_INIT}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS_INIT}")

set(CLANG_COMMON_FLAGS "")

foreach(arch ${_archs})
  set(CLANG_COMMON_FLAGS "${CLANG_COMMON_FLAGS} -arch ${arch}")
endforeach()

set(CLANG_COMMON_FLAGS "${CLANG_COMMON_FLAGS} -fno-common -fblocks")

if(NOT DEFINED CMAKE_CLANG_ENABLE_MODULES)
  set(CMAKE_CLANG_ENABLE_MODULES ON CACHE BOOL "Enable the modules language feature.")
endif()

if(NOT DEFINED CMAKE_CLANG_MODULES_AUTOLINK)
  set(CMAKE_CLANG_MODULES_AUTOLINK ON CACHE BOOL "Enable the autolink language feature.")
endif()

if(NOT DEFINED CMAKE_CLANG_DEFINES_MODULE)
  set(CMAKE_CLANG_DEFINES_MODULE ON CACHE BOOL "Treated as defining its own module.")
endif()

if(NOT DEFINED CMAKE_CLANG_PRODUCT_MODULE_NAME)
  set(CMAKE_CLANG_PRODUCT_MODULE_NAME "" CACHE STRING "The name to use for the source code module constructed for this target, and which will be used to import the module in implementation source files.")
endif()

if(NOT DEFINED CMAKE_CLANG_MODULE_MAP_FILE)
  set(CMAKE_CLANG_MODULE_MAP_FILE "" CACHE STRING "Load this module map file.")
endif()

if(NOT DEFINED CMAKE_CLANG_BUILTIN_MODULE_MAP)
  set(CMAKE_CLANG_BUILTIN_MODULE_MAP ON CACHE BOOL "Load the clang builtins module map file.")
endif()

if(CMAKE_CLANG_ENABLE_MODULES)
  set(CLANG_MODULE_FLAGS "")

  if(CMAKE_CLANG_DEFINES_MODULE)
    if(NOT CMAKE_CLANG_PRODUCT_MODULE_NAME STREQUAL "")
      set(CLANG_MODULE_FLAGS "${CLANG_MODULE_FLAGS} -fmodule-name=${CMAKE_CLANG_PRODUCT_MODULE_NAME}")
    endif()

    if(NOT CMAKE_CLANG_MODULE_MAP_FILE STREQUAL "")
      set(CLANG_MODULE_FLAGS "${CLANG_MODULE_FLAGS} -fmodule-map-file=${CMAKE_CLANG_MODULE_MAP_FILE}")
    endif()
  endif()

  if(CMAKE_CLANG_BUILTIN_MODULE_MAP)
    set(CLANG_MODULE_FLAGS "${CLANG_MODULE_FLAGS} -fbuiltin-module-map")
  endif()

  if(CMAKE_CLANG_MODULES_AUTOLINK)
    set(CLANG_MODULE_FLAGS "${CLANG_MODULE_FLAGS} -fautolink")
  endif()

  set(CMAKE_C_FLAGS "${CLANG_COMMON_FLAGS} -fmodules ${CLANG_MODULE_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CLANG_COMMON_FLAGS} -fcxx-modules ${CLANG_MODULE_FLAGS}")
endif()

message(STATUS "Build for ${_triple} contains ${_archs}, using sdk ${CMAKE_OSX_SYSROOT}")

if(NOT DEFINED CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 11)
endif()

if(NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 14)
endif()

if(NOT DEFINED CMAKE_C_EXTENSIONS)
  set(CMAKE_C_EXTENSIONS ON)
endif()

if(NOT DEFINED CMAKE_CXX_EXTENSIONS)
  set(CMAKE_CXX_EXTENSIONS ON)
endif()

if(NOT DEFINED CMAKE_Swift_LANGUAGE_VERSION)
  set(CMAKE_Swift_LANGUAGE_VERSION 5)
endif()

macro(aux_swift_source_directory _dir _variable)
  file(GLOB ${_variable} ${_dir}/*.swift)
endmacro()

message(STATUS "xcrun toolchain C flags: ${CMAKE_C_FLAGS}")
message(STATUS "xcrun toolchain C++ flags: ${CMAKE_CXX_FLAGS}")
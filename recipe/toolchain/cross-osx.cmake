# this one is important
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_PLATFORM Darwin)
#this one not so much
set(CMAKE_SYSTEM_VERSION 10.15)

# specify the cross compiler
#set(CMAKE_C_COMPILER $ENV{CC})
set(CMAKE_C_COMPILER "/usr/local/opt/llvm/bin/clang" CACHE FILEPATH "C compiler")
set(CMAKE_CXX_COMPILER "/usr/local/opt/llvm/bin/clang++" CACHE FILEPATH "C++ compiler")

# where is the target environment
set(CMAKE_SYSROOT "${CMAKE_OSX_SYSROOT}" CACHE PATH "macOS SDK path")
#set(CMAKE_FIND_ROOT_PATH $ENV{PREFIX} $ENV{BUILD_PREFIX}/$ENV{HOST}/sysroot)

message("CMAKE_SYSROOT: ${CMAKE_OSX_SYSROOT}")
execute_process (
  COMMAND bash "xcrun --sdk macosx --show-sdk-path"
  COMMAND bash "ls /Applications/Xcode_15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs"
  COMMAND bash "ls ${CMAKE_OSX_SYSROOT}/usr/"
  COMMAND bash "ls ${CMAKE_OSX_SYSROOT}/usr/include/"
  COMMAND bash "ls ${CMAKE_OSX_SYSROOT}/usr/include/c++/"
  COMMAND bash "ls ${CMAKE_OSX_SYSROOT}/usr/include/c++/v1"
)
#message("CMAKE_FIND_ROOT_PATH: ${CMAKE_FIND_ROOT_PATH}")


# Explicitly use libc++ headers and ensure they take precede
set(CMAKE_CXX_FLAGS_INIT "-isystem ${CMAKE_OSX_SYSROOT}/usr/include/c++/v1" CACHE STRING "")
#set(CMAKE_CXX_FLAGS_INIT "-isystem /usr/local/opt/llvm/include/c++/v1" CACHE STRING "")

set(RUN_RESULT "0" CACHE STRING "Result of try_run() for cross-compilation")

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# god-awful hack because it seems to not run correct tests to determine this:
set(__CHAR_UNSIGNED___EXITCODE 1)

# this one is important
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_PLATFORM Darwin)
#this one not so much
set(CMAKE_SYSTEM_VERSION 10.15)

# specify the cross compiler
set(CMAKE_C_COMPILER $ENV{CC} CACHE FILEPATH "C compiler")
set(CMAKE_CXX_COMPILER $ENV{CXX} CACHE FILEPATH "C++ compiler")

# where is the target environment
set(CMAKE_FIND_ROOT_PATH $ENV{PREFIX} $ENV{BUILD_PREFIX}/$ENV{HOST}/sysroot)
set(CMAKE_SYSROOT "${CMAKE_OSX_SYSROOT}" CACHE PATH "macOS SDK path")

# Explicitly use libc++ headers and ensure they take precedence
# (commented out, may not be necessary)
#set(CMAKE_CXX_FLAGS_INIT "-isystem /opt/homebrew/opt/llvm/include/c++/v1" CACHE STRING "")

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# god-awful hack because it seems to not run correct tests to determine this:
set(__CHAR_UNSIGNED___EXITCODE 1)

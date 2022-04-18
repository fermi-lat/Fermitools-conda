# Fermitools CMAKE build system
# Author: Alexander Reustle (2022)
cmake_minimum_required(VERSION 3.18)

project(
  Fermitools
  VERSION 2.1.0
  LANGUAGES CXX C
  DESCRIPTION "Fermi Sciencetools"
)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

## Options. Activate at configure time with `-D<OPTION>=ON`
option(FERMI_BUILD_ROOT "Build the CERN ROOT components. Requires ROOT!" OFF)

## CMake tool support packages. These provide additional funcitons to our Cmake files.
include(CMakePackageConfigHelpers)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)
include(GNUInstallDirs)
include(CTest)

## The local cmake modules path.
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

## Externals: The dependent packages on which the Sciencetools relies. ##
find_package(CLHEP REQUIRED)
find_package(Minuit2 REQUIRED)
find_package(OpenMP REQUIRED COMPONENTS CXX)
find_package(PkgConfig REQUIRED)
find_package(SWIG 3.0.1 REQUIRED COMPONENTS python)
set(UseSWIG_TARGET_NAME_PREFERENCE STANDARD)

set(Python3_FIND_VIRTUALENV FIRST)
find_package(Python3 3.7 REQUIRED COMPONENTS Development Interpreter)

## Pkg-Config Externals ##
pkg_check_modules(cfitsio REQUIRED IMPORTED_TARGET GLOBAL cfitsio)
pkg_check_modules(cppunit REQUIRED IMPORTED_TARGET GLOBAL cppunit)
pkg_check_modules(f2c REQUIRED IMPORTED_TARGET GLOBAL f2c)
pkg_check_modules(fftw3 REQUIRED IMPORTED_TARGET GLOBAL fftw3)
pkg_check_modules(gsl REQUIRED IMPORTED_TARGET GLOBAL gsl)
pkg_check_modules(wcslib REQUIRED IMPORTED_TARGET GLOBAL wcslib)
pkg_check_modules(healpix_cxx REQUIRED IMPORTED_TARGET GLOBAL healpix_cxx)
pkg_check_modules(xerces-c REQUIRED IMPORTED_TARGET GLOBAL xerces-c)

## Make the targets visible in other CMake files.
set_target_properties(
  CLHEP::CLHEP
  Minuit2::Minuit2
  Minuit2::Minuit2Math
  OpenMP::OpenMP_CXX
  Python3::Python
  PROPERTIES IMPORTED_GLOBAL TRUE
)

## Handle root.
if(FERMI_BUILD_ROOT)
  find_package(ROOT REQUIRED)
  set_target_properties(
    ROOT::Core
    PROPERTIES IMPORTED_GLOBAL TRUE
  )
endif()

###############################
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.h.in config.h)
include_directories(${PROJECT_BINARY_PATH})

## The full colleciton of Sciencetools packages.
list(
  APPEND fermi_components
  ape
  facilities
  embed_python
  hoops
  tip
  xmlBase
  astro
  flux
  st_facilities
  st_stream
  st_graph
  st_app
  healpix
  evtbin
  timeSystem
  catalogAccess
  sourceIdentify
  optimizers
  celestialSources
  irfs
  dataSubselector
  map_tools
  Likelihood
  pyLikelihood
  # skymaps # <-- Small ROOT dependence must be optionally removed from the swig module.
  SolarSystemTools
  rspgen
)

foreach(pkg ${fermi_components})
  add_subdirectory(../${pkg} ${CMAKE_BINARY_DIR}/${pkg})
endforeach()

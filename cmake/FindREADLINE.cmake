# FindREADLINE.cmake
#
# Finds the READLINE library
#
# This will define the following variables
#
# READLINE_FOUND READLINE_INCLUDE_DIRS READLINE_LIBRARY
#
# along with the following input targets
#
# READLINE::READLINE
#
# Author: Alex Reustle - Alexander.Reustle@nasa.gov

# ##############################################################################
# Find the necessary headers and libraries
# ##############################################################################

find_path(READLINE_INCLUDE_DIR
          REQUIRED
          NAMES readline.h
          HINTS ${CMAKE_INSTALL_PREFIX}
          PATH_SUFFIXES readline)

find_library(READLINE_LIBRARY
             NAMES readline
             HINTS ${CMAKE_INSTALL_PREFIX}
             PATH_SUFFIXES lib lib64)

find_library(TERMCAP_LIBRARY
             NAMES tinfo termcap ncursesw ncurses cursesw curses
             HINTS ${CMAKE_INSTALL_PREFIX}
             PATH_SUFFIXES lib lib64)

# ##############################################################################
# Bookkeeping and warning if anything not found
mark_as_advanced(READLINE_FOUND
                 READLINE_INCLUDE_DIR
                 READLINE_LIBRARY
                 TERMCAP_LIBRARY
                 )

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(READLINE
                                  REQUIRED_VARS
                                  READLINE_INCLUDE_DIR
                                  READLINE_LIBRARY
                                  TERMCAP_LIBRARY)

# ##############################################################################
# Properly set variables and targets

# Set include dirs to parent, to enable includes like include
# <readline/readline.h>
if(READLINE_FOUND)
  get_filename_component(READLINE_INCLUDE_DIRS ${READLINE_INCLUDE_DIR}
                         DIRECTORY)
endif()

# Create the target and declare the target properties.
if(READLINE_FOUND AND NOT TARGET READLINE::READLINE)

  add_library(READLINE::READLINE
              INTERFACE
              IMPORTED
              GLOBAL)
  target_include_directories(READLINE::READLINE
                             INTERFACE "${READLINE_INCLUDE_DIRS}")
  target_link_libraries(READLINE::READLINE
                        INTERFACE "${READLINE_LIBRARY}" "${TERMCAP_LIBRARY}")

endif()

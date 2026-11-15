# Use the CMake package config file in libjpeg-turbo v2.1 or later to find the
# TurboJPEG API library and header.

set(TURBOJPEG_VERSION "" CACHE STRING
  "Minimum version of libjpeg-turbo containing the desired TurboJPEG API functionality")
option(TURBOJPEG_EXACT
  "Require the exact version of libjpeg-turbo specified in TURBOJPEG_VERSION"
  FALSE)
boolean_number(TURBOJPEG_EXACT)
set(TURBOJPEG_PATH "" CACHE PATH
  "Search only this path for libjpeg-turbo")
option(TURBOJPEG_STATIC
  "Link with the static TurboJPEG API library rather than the shared TurboJPEG API library"
  FALSE)
boolean_number(TURBOJPEG_STATIC)

set(EXACT "")
if(TURBOJPEG_EXACT AND TURBOJPEG_VERSION)
  set(EXACT EXACT)
endif()

if(TURBOJPEG_PATH)
  find_package(libjpeg-turbo ${TURBOJPEG_VERSION} ${EXACT} REQUIRED
    PATHS ${TURBOJPEG_PATH} NO_DEFAULT_PATH)
else()
  find_package(libjpeg-turbo ${TURBOJPEG_VERSION} ${EXACT} REQUIRED)
endif()

set(TURBOJPEG_TARGET libjpeg-turbo::turbojpeg)
if(TURBOJPEG_STATIC)
  set(TURBOJPEG_TARGET libjpeg-turbo::turbojpeg-static)
endif()
if(NOT TARGET ${TURBOJPEG_TARGET})
  message(FATAL_ERROR "Target ${TURBOJPEG_TARGET} does not exist in libjpeg-turbo package")
endif()
get_target_property(TURBOJPEG_LIB ${TURBOJPEG_TARGET}
  IMPORTED_LOCATION_RELEASE)
if(TURBOJPEG_LIB STREQUAL "TURBOJPEG_LIB-NOTFOUND")
  get_target_property(TURBOJPEG_LIB ${TURBOJPEG_TARGET} IMPORTED_LOCATION_NONE)
endif()
message(STATUS "Found TurboJPEG: ${TURBOJPEG_LIB} (found version \"${libjpeg-turbo_VERSION}\")")

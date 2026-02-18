# This module uses the CMake package config file in libjpeg-turbo v2.1 or later
# to find the TurboJPEG API library and header.

set(TURBOJPEG_VERSION "" CACHE STRING
  "Minimum version of libjpeg-turbo containing the desired TurboJPEG API functionality")
option(TURBOJPEG_EXACT
  "Require the exact version of libjpeg-turbo specified in TURBOJPEG_VERSION"
  FALSE)
set(TURBOJPEG_PATH "" CACHE PATH
  "Search only this path for libjpeg-turbo")
option(TURBOJPEG_STATIC
  "Link with the static TurboJPEG API library rather than the shared TurboJPEG API library"
  FALSE)

if(TJPEG_INCLUDE_DIR OR TJPEG_LIBRARY)
  message(WARNING
    "The build system now uses the CMake package config file in libjpeg-turbo v2.1 or later to find the TurboJPEG API library and header.  This can be customized with the TURBOJPEG_VERSION, TURBOJPEG_EXACT, TURBOJPEG_PATH, and TURBOJPEG_STATIC CMake variables.  TJPEG_INCLUDE_DIR and TJPEG_LIBRARY are ignored.")
endif()

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
get_target_property(TURBOJPEG_LIB ${TURBOJPEG_TARGET}
  IMPORTED_LOCATION_RELEASE)
message(STATUS "Found TurboJPEG: ${TURBOJPEG_LIB} (found version \"${libjpeg-turbo_VERSION}\")")

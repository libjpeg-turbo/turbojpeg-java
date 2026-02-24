cmake_minimum_required(VERSION 2.8.12...3.28)

set(CMAKE_C_FLAGS_RELEASE_INITIALIZED_TO_DEFAULT 1)
if(CMAKE_C_FLAGS_RELEASE)
  set(CMAKE_C_FLAGS_RELEASE_INITIALIZED_TO_DEFAULT 0)
endif()
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INITIALIZED_TO_DEFAULT 1)
if(CMAKE_C_FLAGS_RELWITHDEBINFO)
  set(CMAKE_C_FLAGS_RELWITHDEBINFO_INITIALIZED_TO_DEFAULT 0)
endif()

project(turbojpeg-java C)
set(VERSION 3.1.80)
set(MSVC_LIKE 0)
if(MSVC OR CMAKE_C_SIMULATE_ID STREQUAL "MSVC")
  set(MSVC_LIKE 1)
endif()

# The TurboJPEG/Java build system has never supported and will never support
# being integrated into another build system using add_subdirectory(), because
# doing so would require that we (minimally):
#
# 1. avoid using certain CMake variables, such as CMAKE_SOURCE_DIR,
#    CMAKE_BINARY_DIR, and CMAKE_PROJECT_NAME;
# 2. avoid using implicit include directories and relative paths;
# 3. optionally provide a way to skip the installation of TurboJPEG/Java
#    components when the 'install' target is built;
# 4. optionally provide a way to postfix target names, to avoid namespace
#    conflicts;
# 5. restructure the top-level CMakeLists.txt so that it properly sets the
#    PROJECT_VERSION variable; and
# 6. design automated regression tests to ensure that new commits don't break
#    any of the above.
#
# Even if we did all of that, issues would still arise, because it is
# impossible for an upstream build system to anticipate the widely varying
# needs of every downstream build system.  That's why the CMake
# ExternalProject_Add() function exists.  Downstream projects that wish to
# integrate TurboJPEG/Java as a subdirectory should either use
# ExternalProject_Add() or make downstream modifications to the TurboJPEG/Java
# build system to suit their specific needs.  Please do not file bug reports,
# feature requests, or pull requests regarding this.
if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  message(FATAL_ERROR "The TurboJPEG/Java build system cannot be integrated into another build system using add_subdirectory().  Use ExternalProject_Add() instead.")
endif()

get_property(GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY
  GENERATOR_IS_MULTI_CONFIG)
# If the GENERATOR_IS_MULTI_CONFIG property doesn't exist (CMake < 3.9), then
# set the GENERATOR_IS_MULTI_CONFIG variable manually if the generator is
# Visual Studio or Xcode (the only multi-config generators in CMake < 3.9).
if(NOT GENERATOR_IS_MULTI_CONFIG AND (MSVC_IDE OR XCODE))
  set(GENERATOR_IS_MULTI_CONFIG TRUE)
endif()

string(TIMESTAMP DEFAULT_BUILD "%Y%m%d")
set(BUILD ${DEFAULT_BUILD} CACHE STRING "Build string (default: ${DEFAULT_BUILD})")

# NOTE: On Windows, this does nothing except when using MinGW or Cygwin.
# CMAKE_BUILD_TYPE has no meaning in Visual Studio, and it always defaults to
# Debug when using NMake.
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()
message(STATUS "CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}")

message(STATUS "VERSION = ${VERSION}, BUILD = ${BUILD}")

# Detect CPU type and whether we're building 64-bit or 32-bit code
math(EXPR BITS "${CMAKE_SIZEOF_VOID_P} * 8")
string(TOLOWER ${CMAKE_SYSTEM_PROCESSOR} CMAKE_SYSTEM_PROCESSOR_LC)
if(CMAKE_SYSTEM_PROCESSOR_LC MATCHES "x86_64" OR
  CMAKE_SYSTEM_PROCESSOR_LC MATCHES "amd64" OR
  CMAKE_SYSTEM_PROCESSOR_LC MATCHES "i[0-9]86" OR
  CMAKE_SYSTEM_PROCESSOR_LC MATCHES "x86" OR
  CMAKE_SYSTEM_PROCESSOR_LC MATCHES "ia32")
  if(BITS EQUAL 64 OR CMAKE_C_COMPILER_ABI MATCHES "ELF X32")
    if(WIN32)
      set(PKGARCH x64)
    else()
      set(PKGARCH x86_64)
    endif()
  else()
    if(WIN32)
      set(PKGARCH x86)
    else()
      set(PKGARCH i386)
    endif()
  endif()
elseif(CMAKE_SYSTEM_PROCESSOR_LC STREQUAL "aarch64" OR
  CMAKE_SYSTEM_PROCESSOR_LC MATCHES "^arm")
  if(BITS EQUAL 64)
    if(WIN32 OR APPLE)
      set(PKGARCH arm64)
    else()
      set(PKGARCH aarch64)
    endif()
  else()
    if(WIN32 OR APPLE)
      set(PKGARCH arm)
    else()
      set(PKGARCH aarch32)
    endif()
  endif()
elseif(CMAKE_SYSTEM_PROCESSOR_LC MATCHES "^ppc" OR
  CMAKE_SYSTEM_PROCESSOR_LC MATCHES "^powerpc")
  set(PKGARCH powerpc)
else()
  set(PKGARCH ${CMAKE_SYSTEM_PROCESSOR_LC})
endif()

set(COUNT 1)
foreach(ARCH ${CMAKE_OSX_ARCHITECTURES})
  math(EXPR COUNT "${COUNT}+1")
endforeach()
if(COUNT GREATER 1)
  set(PKGARCH universal)
elseif(CMAKE_OSX_ARCHITECTURES MATCHES "x86_64" OR
  CMAKE_OSX_ARCHITECTURES MATCHES "arm64" OR
  CMAKE_OSX_ARCHITECTURES MATCHES "i386")
  set(PKGARCH ${CMAKE_OSX_ARCHITECTURES})
elseif(CMAKE_OSX_ARCHITECTURES MATCHES "ppc")
  set(PKGARCH powerpc)
endif()
if(MSVC_IDE AND CMAKE_GENERATOR_PLATFORM MATCHES "arm64")
  set(PKGARCH arm64)
endif()

if(WIN32)
  set(PKGOS windows)
elseif(APPLE)
  set(PKGOS macos)
else()
  string(TOLOWER ${CMAKE_SYSTEM_NAME} CMAKE_SYSTEM_NAME_LC)
  set(PKGOS ${CMAKE_SYSTEM_NAME_LC})
endif()

message(STATUS "${BITS}-bit build (${PKGARCH})")


###############################################################################
# INSTALL DIRECTORIES
###############################################################################

if(WIN32)
  set(CMAKE_INSTALL_DEFAULT_PREFIX "c:/${CMAKE_PROJECT_NAME}")
  if(BITS EQUAL 64)
    set(CMAKE_INSTALL_DEFAULT_PREFIX "${CMAKE_INSTALL_DEFAULT_PREFIX}64")
  endif()
else()
  if(NOT CMAKE_INSTALL_DEFAULT_PREFIX)
    set(CMAKE_INSTALL_DEFAULT_PREFIX /opt/${CMAKE_PROJECT_NAME})
  endif()
endif()
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_DEFAULT_PREFIX}" CACHE PATH
    "Directory into which to install TurboJPEG/Java (default: ${CMAKE_INSTALL_DEFAULT_PREFIX})"
    FORCE)
endif()
message(STATUS "CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}")

# When the prefix is /opt/${CMAKE_PROJECT_NAME}, we assume that an "official"
# build is being created, and thus we install things into specific locations.

if(CMAKE_INSTALL_PREFIX STREQUAL "${CMAKE_INSTALL_DEFAULT_PREFIX}")
  set(CMAKE_INSTALL_DEFAULT_DATAROOTDIR "")
  set(CMAKE_INSTALL_DEFAULT_DOCDIR "<CMAKE_INSTALL_DATAROOTDIR>/doc")
  set(CMAKE_INSTALL_DEFAULT_JAVADIR "<CMAKE_INSTALL_DATAROOTDIR>")
endif()

include(cmakescripts/GNUInstallDirs.cmake)

macro(report_directory var)
  if(CMAKE_INSTALL_${var} STREQUAL CMAKE_INSTALL_FULL_${var})
    message(STATUS "CMAKE_INSTALL_${var} = ${CMAKE_INSTALL_${var}}")
  else()
    message(STATUS "CMAKE_INSTALL_${var} = ${CMAKE_INSTALL_${var}} (${CMAKE_INSTALL_FULL_${var}})")
  endif()
  mark_as_advanced(CLEAR CMAKE_INSTALL_${var})
endmacro()

if(NOT DEFINED CMAKE_INSTALL_DEFAULT_JAVADIR)
  set(CMAKE_INSTALL_DEFAULT_JAVADIR "<CMAKE_INSTALL_DATAROOTDIR>/java")
endif()
GNUInstallDirs_set_install_dir(JAVADIR
  "The directory into which Java classes should be installed")
GNUInstallDirs_get_absolute_install_dir(CMAKE_INSTALL_FULL_JAVADIR
  CMAKE_INSTALL_JAVADIR)
mark_as_advanced(CLEAR CMAKE_INSTALL_JAVADIR)

set(DIRLIST "DATAROOTDIR;DOCDIR;JAVADIR")
foreach(dir ${DIRLIST})
  report_directory(${dir})
endforeach()


###############################################################################
# CONFIGURATION OPTIONS
###############################################################################

macro(boolean_number var)
  if(${var})
    set(${var} 1 ${ARGN})
  else()
    set(${var} 0 ${ARGN})
  endif()
endmacro()

macro(report_option var desc)
  if(${var})
    message(STATUS "${desc} enabled (${var} = ${${var}})")
  else()
    message(STATUS "${desc} disabled (${var} = ${${var}})")
  endif()
endmacro()


###############################################################################
# COMPILER SETTINGS
###############################################################################

string(TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_UC)

if(MSVC_LIKE)
  option(WITH_CRT_DLL
    "Link the TurboJPEG JNI library with the C run-time DLL (msvcr*.dll) instead of the static C run-time library (libcmt*.lib.)  The default is to use the C run-time DLL only with the libraries and executables that need it."
    FALSE)
  boolean_number(WITH_CRT_DLL)
  if(NOT WITH_CRT_DLL)
    # Use the static C library for all build types
    if(CMAKE_VERSION VERSION_EQUAL "3.15" OR
      CMAKE_VERSION VERSION_GREATER "3.15")
      if(CMAKE_BUILD_TYPE_UC STREQUAL "DEBUG")
        set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDebug)
      elseif(MSVC_IDE)
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
      else()
        set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)
      endif()
      message(STATUS "Visual C++ run-time library: ${CMAKE_MSVC_RUNTIME_LIBRARY} (WITH_CRT_DLL = ${WITH_CRT_DLL})")
    elseif(MSVC)
      foreach(var CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO)
        if(${var} MATCHES "/MD")
          string(REGEX REPLACE "/MD" "/MT" ${var} "${${var}}")
        endif()
      endforeach()
    endif()
  endif()
  add_definitions(-D_CRT_NONSTDC_NO_WARNINGS)
endif()

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_C_COMPILER_ID MATCHES "Clang")
  # Use the maximum optimization level for release builds
  foreach(build_type RELEASE RELWITHDEBINFO)
    if(CMAKE_C_FLAGS_${build_type} MATCHES "-O2" AND
      CMAKE_C_FLAGS_${build_type}_INITIALIZED_TO_DEFAULT)
      string(REGEX REPLACE "-O2" "-O3" CMAKE_C_FLAGS_${build_type}
        "${CMAKE_C_FLAGS_${build_type}}")
    endif()
  endforeach()
endif()

set(EFFECTIVE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${CMAKE_BUILD_TYPE_UC}}")
message(STATUS "Compiler flags = ${EFFECTIVE_C_FLAGS}")

set(EFFECTIVE_LD_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_${CMAKE_BUILD_TYPE_UC}}")
message(STATUS "Linker flags = ${EFFECTIVE_LD_FLAGS}")

if(UNIX AND NOT APPLE)
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/conftest.map "VERS_1 { global: *; };")
  set(CMAKE_REQUIRED_FLAGS
    "-Wl,--version-script,${CMAKE_CURRENT_BINARY_DIR}/conftest.map")
  include(CheckCSourceCompiles)
  check_c_source_compiles("int main(void) { return 0; }" HAVE_VERSION_SCRIPT)
  set(CMAKE_REQUIRED_FLAGS)
  file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/conftest.map)
  if(HAVE_VERSION_SCRIPT)
    message(STATUS "Linker supports GNU-style version scripts")
    set(MAPFLAG "-Wl,--version-script,")
    set(TJMAPFLAG "-Wl,--version-script,")
  else()
    message(STATUS "Linker does not support GNU-style version scripts")
  endif()
endif()


###############################################################################
# TARGETS
###############################################################################

if(NOT TURBOJPEG_VERSION)
  set(TURBOJPEG_VERSION 3.1.0)
endif()
include(cmakescripts/FindTurboJPEG.cmake)

find_package(JNI REQUIRED)
include_directories(${JAVA_INCLUDE_PATH} ${JAVA_INCLUDE_PATH2})

add_library(turbojpeg-jni SHARED turbojpeg-jni.c)
if(APPLE AND (NOT CMAKE_OSX_DEPLOYMENT_TARGET OR
              CMAKE_OSX_DEPLOYMENT_TARGET VERSION_GREATER 10.4))
  if(NOT CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG)
    set(CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG "-Wl,-rpath,")
  endif()
  set_target_properties(turbojpeg-jni PROPERTIES MACOSX_RPATH 1)
endif()
if(TJMAPFLAG)
  set_target_properties(turbojpeg-jni PROPERTIES
    LINK_FLAGS "${TJMAPFLAG}${CMAKE_SOURCE_DIR}/turbojpeg-jni-mapfile")
endif()
target_link_libraries(turbojpeg-jni ${TURBOJPEG_TARGET})

find_package(Java REQUIRED)

# Allow the Java compiler flags to be set using an environment variable
if(NOT DEFINED CMAKE_JAVA_COMPILE_FLAGS AND DEFINED ENV{JAVAFLAGS})
  set(CMAKE_JAVA_COMPILE_FLAGS $ENV{JAVAFLAGS})
endif()

include(UseJava)

set(CMAKE_JAVA_COMPILE_FLAGS "${CMAKE_JAVA_COMPILE_FLAGS} -J-Dfile.encoding=UTF8")
message(STATUS "CMAKE_JAVA_COMPILE_FLAGS = ${CMAKE_JAVA_COMPILE_FLAGS}")
string(REGEX REPLACE " " ";" CMAKE_JAVA_COMPILE_FLAGS "${CMAKE_JAVA_COMPILE_FLAGS}")

set(JAVAARGS "" CACHE STRING "Additional arguments to pass to java when running unit tests (example: -d32)")
message(STATUS "JAVAARGS = ${JAVAARGS}")

set(JAVA_SOURCES org/libjpegturbo/turbojpeg/TJ.java
  org/libjpegturbo/turbojpeg/TJCompressor.java
  org/libjpegturbo/turbojpeg/TJCustomFilter.java
  org/libjpegturbo/turbojpeg/TJDecompressor.java
  org/libjpegturbo/turbojpeg/TJException.java
  org/libjpegturbo/turbojpeg/TJLoader.java
  org/libjpegturbo/turbojpeg/TJScalingFactor.java
  org/libjpegturbo/turbojpeg/TJTransform.java
  org/libjpegturbo/turbojpeg/TJTransformer.java
  org/libjpegturbo/turbojpeg/YUVImage.java
  org/scijava/util/ClassUtils.java
  org/scijava/util/FileUtils.java
  org/scijava/util/PlatformUtils.java
  TJUnitTest.java
  TJComp.java
  TJDecomp.java
  TJTran.java
  TJBench.java)

if(MSYS)
  # UGLY HACK ALERT: If we don't do this, then UseJava.cmake will separate
  # class path members with a semicolon, which is interpreted as a command
  # separator by the MSYS shell.
  set(CMAKE_HOST_SYSTEM_NAME_BAK ${CMAKE_HOST_SYSTEM_NAME})
  set(CMAKE_HOST_SYSTEM_NAME "MSYS")
endif()
add_jar(turbojpeg-java ${JAVA_SOURCES} OUTPUT_NAME turbojpeg
  ENTRY_POINT TJBench)
if(MSYS)
  set(CMAKE_HOST_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME_BAK})
endif()

add_custom_target(javadoc COMMAND
  javadoc -notimestamp -d ${CMAKE_CURRENT_SOURCE_DIR}/doc
    -sourcepath ${CMAKE_CURRENT_SOURCE_DIR} org.libjpegturbo.turbojpeg)
set(JAVACLASSPATH ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/turbojpeg-java.dir)
if(Java_VERSION_MAJOR GREATER 9)
  add_custom_target(javah
    COMMAND javac -h ${CMAKE_CURRENT_SOURCE_DIR} -classpath ${JAVACLASSPATH}
      -d ${CMAKE_CURRENT_BINARY_DIR}/__unused
      ${CMAKE_CURRENT_SOURCE_DIR}/org/libjpegturbo/turbojpeg/TJ.java
      ${CMAKE_CURRENT_SOURCE_DIR}/org/libjpegturbo/turbojpeg/TJCompressor.java
      ${CMAKE_CURRENT_SOURCE_DIR}/org/libjpegturbo/turbojpeg/TJDecompressor.java
      ${CMAKE_CURRENT_SOURCE_DIR}/org/libjpegturbo/turbojpeg/TJTransformer.java)
else()
  add_custom_target(javah
    COMMAND javah -d ${CMAKE_CURRENT_SOURCE_DIR} -classpath ${JAVACLASSPATH}
      org.libjpegturbo.turbojpeg.TJ
    COMMAND javah -d ${CMAKE_CURRENT_SOURCE_DIR} -classpath ${JAVACLASSPATH}
      org.libjpegturbo.turbojpeg.TJCompressor
    COMMAND javah -d ${CMAKE_CURRENT_SOURCE_DIR} -classpath ${JAVACLASSPATH}
      org.libjpegturbo.turbojpeg.TJDecompressor
    COMMAND javah -d ${CMAKE_CURRENT_SOURCE_DIR} -classpath ${JAVACLASSPATH}
      org.libjpegturbo.turbojpeg.TJTransformer)
endif()

if(CMAKE_VERSION VERSION_EQUAL "3.4" OR CMAKE_VERSION VERSION_GREATER "3.4")
  install_jar(turbojpeg-java DESTINATION ${CMAKE_INSTALL_FULL_JAVADIR}
    COMPONENT java)
else()
  install_jar(turbojpeg-java ${CMAKE_INSTALL_FULL_JAVADIR})
endif()


###############################################################################
# TESTS
###############################################################################

add_subdirectory(md5)

if(GENERATOR_IS_MULTI_CONFIG)
  set(OBJDIR "\${CTEST_CONFIGURATION_TYPE}/")
else()
  set(OBJDIR "")
endif()

enable_testing()

add_test(NAME TJUnitTest
  COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
    TJUnitTest)
add_test(NAME TJUnitTest-yuv
  COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
    TJUnitTest -yuv)
add_test(NAME TJUnitTest-yuv-nopad
  COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
    TJUnitTest -yuv -noyuvpad)
add_test(NAME TJUnitTest-lossless
  COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
    TJUnitTest -lossless)
add_test(NAME TJUnitTest-bi
  COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
    TJUnitTest -bi)
add_test(NAME TJUnitTest-bi-yuv
  COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
    TJUnitTest -bi -yuv)
add_test(NAME TJUnitTest-bi-yuv-nopad
  COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
    TJUnitTest -bi -yuv -noyuvpad)
add_test(NAME TJUnitTest-bi-lossless
  COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
    TJUnitTest -bi -lossless)
add_test(NAME TJUnitTest-bmp
  COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
    TJUnitTest -bmp)
add_test(NAME TJUnitTest12
  COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
    TJUnitTest -precision 12)
foreach(sample_bits 2 3 4 5 6 7 9 10 11 12 13 14 15 16)
  add_test(NAME TJUnitTest${sample_bits}-lossless
    COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
        TJUnitTest -precision ${sample_bits} -lossless)
  add_test(NAME TJUnitTest${sample_bits}-bmp
    COMMAND ${Java_JAVA_EXECUTABLE} ${JAVAARGS} -cp turbojpeg.jar
      TJUnitTest -precision ${sample_bits} -bmp)
endforeach()

add_custom_target(testclean COMMAND ${CMAKE_COMMAND} -P
  ${CMAKE_CURRENT_SOURCE_DIR}/cmakescripts/testclean.cmake)

configure_file(test/tjbenchtest.in test/tjbenchtest @ONLY)
configure_file(test/tjcomptest.in test/tjcomptest @ONLY)
configure_file(test/tjdecomptest.in test/tjdecomptest @ONLY)
configure_file(test/tjtrantest.in test/tjtrantest @ONLY)
add_custom_target(tjtest COMMAND ${CMAKE_COMMAND} -DPRECISION=8
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  DEPENDS ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/test/tjbenchtest)
add_custom_target(tjtest12 COMMAND ${CMAKE_COMMAND} -DPRECISION=12
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  DEPENDS ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/test/tjbenchtest)
add_custom_target(tjtest16 COMMAND ${CMAKE_COMMAND} -DPRECISION=2
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=3
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=4
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=5
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=6
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=7
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=9
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=10
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=11
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=13
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=14
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=15
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  COMMAND ${CMAKE_COMMAND} -DPRECISION=16
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
  DEPENDS ${CMAKE_SOURCE_DIR}/cmakescripts/tjbenchtest.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/test/tjbenchtest)
add_custom_target(tjexampletest COMMAND ${CMAKE_COMMAND}
    -P ${CMAKE_SOURCE_DIR}/cmakescripts/tjexampletest.cmake
  DEPENDS ${CMAKE_SOURCE_DIR}/cmakescripts/tjexampletest.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/test/tjcomptest
    ${CMAKE_CURRENT_BINARY_DIR}/test/tjdecomptest
    ${CMAKE_CURRENT_BINARY_DIR}/test/tjtrantest)


###############################################################################
# INSTALLATION
###############################################################################

install(TARGETS turbojpeg-jni
  LIBRARY DESTINATION ${CMAKE_INSTALL_FULL_JAVADIR} COMPONENT lib
  RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_JAVADIR} COMPONENT bin)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/README.md
  ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.md
  ${CMAKE_CURRENT_SOURCE_DIR}/TJComp.java
  ${CMAKE_CURRENT_SOURCE_DIR}/TJDecomp.java
  ${CMAKE_CURRENT_SOURCE_DIR}/TJTran.java
  DESTINATION ${CMAKE_INSTALL_FULL_DOCDIR} COMPONENT doc)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmakescripts/cmake_uninstall.cmake.in"
  "cmake_uninstall.cmake" IMMEDIATE @ONLY)

add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P cmake_uninstall.cmake)

add_custom_target(dist
  COMMAND git archive --prefix=${CMAKE_PROJECT_NAME}-${VERSION}/ HEAD |
    gzip > ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}-${VERSION}.tar.gz
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

configure_file(release/maketarball.in pkgscripts/maketarball)

add_custom_target(tarball pkgscripts/maketarball
  SOURCES pkgscripts/maketarball)

configure_file(release/makezip.in pkgscripts/makezip)

if(WIN32)
  add_custom_target(zip sh pkgscripts/makezip SOURCES pkgscripts/makezip)
else()
  add_custom_target(zip pkgscripts/makezip SOURCES pkgscripts/makezip)
endif()

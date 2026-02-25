Building TurboJPEG/Java
=======================


Build Requirements
------------------


### All Systems

- [CMake](https://cmake.org) v2.8.12 or later

- JDK or OpenJDK 7 or later

  * Most modern Linux distributions, as well as Solaris 10 and later, include
    JDK or OpenJDK.  For other systems, pre-built JDK binaries can be obtained
    from [Oracle](https://oracle.com/java/technologies/downloads) or
    [Adoptium](https://adoptium.net/temurin/releases).

  * If using JDK 11 or later, CMake 3.10.x or later must also be used.

- The TurboJPEG SDK from
  [libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo/releases) v3.1
  or later

  * The build system uses libjpeg-turbo's CMake package config file to find the
    TurboJPEG API library and header.  You can set the `CMAKE_PREFIX_PATH`
    CMake variable to specify an alternate search location for the CMake
    package config file (for example, **/opt/libjpeg-turbo/lib64/cmake**.)

  * The following advanced CMake variables also control finding and linking
    with the TurboJPEG API library:

      - `TURBOJPEG_VERSION`
      - `TURBOJPEG_EXACT`
      - `TURBOJPEG_PATH`
      - `TURBOJPEG_STATIC`

      Use `ccmake` or `cmake-gui`, as described below, to view documentation
    for those variables.

### Un*x Platforms (including Mac)

- GCC v4.1 (or later) or Clang

### Windows

- Microsoft Visual C++ 2005 or later

  If you don't already have Visual C++, then the easiest way to get it is by
  installing
  [Visual Studio Community Edition](https://visualstudio.microsoft.com),
  which includes everything necessary to build the TurboJPEG JNI library.

  * You can also download and install the standalone Windows SDK (for Windows 7
    or later), which includes command-line versions of the 32-bit and 64-bit
    Visual C++ compilers.
  * If you intend to build TurboJPEG/Java from the command line, then add the
    appropriate compiler and SDK directories to the `INCLUDE`, `LIB`, and
    `PATH` environment variables.  This is generally accomplished by
    executing `vcvars32.bat` or `vcvars64.bat`, which are located in the same
    directory as the compiler.


Sub-Project Builds
------------------

The TurboJPEG/Java build system does not support being included as a
sub-project using the CMake `add_subdirectory()` function.  Use the CMake
`ExternalProject_Add()` function instead.


Ninja
-----

If using Ninja, then replace `make` or `nmake` with `ninja`, and replace the
CMake generator (specified with the `-G` option) with `Ninja`, in all of the
procedures and recipes below.


Build Procedure
---------------

NOTE: The build procedures below assume that CMake is invoked from the command
line, but all of these procedures can be adapted to the CMake GUI as
well.


### Un*x

    cd {build_directory}
    cmake -G"Unix Makefiles" [additional CMake flags] {source_directory}
    make


### Visual C++ (Command Line)

    cd {build_directory}
    cmake -G"NMake Makefiles" -DCMAKE_BUILD_TYPE=Release [additional CMake flags] {source_directory}
    nmake


### Visual C++ (IDE)

Choose the appropriate CMake generator option for your version of Visual Studio
(run `cmake` with no arguments for a list of available generators.)  For
instance:

    cd {build_directory}
    cmake -G"Visual Studio 10" [additional CMake flags] {source_directory}

NOTE: Add "Win64" to the generator name (for example, "Visual Studio 10 Win64")
to build a 64-bit version of TurboJPEG/Java.  A separate build directory must
be used for 32-bit and 64-bit builds.

You can then open **ALL_BUILD.vcproj** in Visual Studio and build one of the
configurations in that project ("Debug", "Release", etc.) to generate a full
build of TurboJPEG/Java.


### Debug Build

Add `-DCMAKE_BUILD_TYPE=Debug` to the CMake command line.  Or, if building
with NMake, remove `-DCMAKE_BUILD_TYPE=Release` (Debug builds are the default
with NMake.)


### Other JDKs

If Java is not in your `PATH`, or if you wish to use an alternate JDK to
build/test TurboJPEG/Java, then (prior to running CMake) set the `JAVA_HOME`
environment variable to the location of the JDK that you wish to use.  The
`Java_JAVAC_EXECUTABLE`, `Java_JAVA_EXECUTABLE`, and `Java_JAR_EXECUTABLE`
CMake variables can also be used to specify alternate commands or locations for
javac, java, and jar (respectively.)  You can also set the
`CMAKE_JAVA_COMPILE_FLAGS` CMake variable or the `JAVAFLAGS` environment
variable to specify arguments that should be passed to the Java compiler when
building the TurboJPEG classes, and the `JAVAARGS` CMake variable to specify
arguments that should be passed to the JRE when running the TurboJPEG Java unit
tests.


### Other Compilers

On Un*x systems, prior to running CMake, you can set the `CC` environment
variable to the command used to invoke the C compiler.


Advanced CMake Options
----------------------

To list and configure other CMake options not specifically mentioned in this
guide, run

    ccmake {source_directory}

or

    cmake-gui {source_directory}

from the build directory after initially configuring the build.  CCMake is a
text-based interactive version of CMake, and CMake-GUI is a GUI version.  Both
will display all variables that are relevant to the TurboJPEG/Java build, their
current values, and a help string describing what they do.


Installing TurboJPEG/Java
=========================

You can use the build system to install TurboJPEG/Java.  To do this, run
`make install` or `nmake install` (or build the "install" target in the Visual
Studio IDE.)  Running `make uninstall` or `nmake uninstall` (or building the
"uninstall" target in the Visual Studio IDE) will uninstall TurboJPEG/Java.

The `CMAKE_INSTALL_PREFIX` CMake variable can be modified in order to install
TurboJPEG/Java into a directory of your choosing.  If you don't specify
`CMAKE_INSTALL_PREFIX`, then the default is:

**c:\turbojpeg-java**<br>
Visual Studio 32-bit build

**c:\turbojpeg-java64**<br>
Visual Studio 64-bit build

**/opt/turbojpeg-java**<br>
Un*x (including Mac)

The default value of `CMAKE_INSTALL_PREFIX` causes the TurboJPEG/Java files to
be installed at the top level of the installation directory.  Changing the
value of `CMAKE_INSTALL_PREFIX` (for instance, to **/usr/local**) causes the
TurboJPEG/Java files to be installed with a directory structure that conforms
to GNU standards.

The `CMAKE_INSTALL_DATAROOTDIR`, `CMAKE_INSTALL_DOCDIR`, and
`CMAKE_INSTALL_JAVADIR` CMake variables allow a finer degree of control over
where specific files in the TurboJPEG/Java distribution should be installed.
These directory variables can either be specified as absolute paths or as paths
relative to `CMAKE_INSTALL_PREFIX` (for instance, setting
`CMAKE_INSTALL_DOCDIR` to **doc** would cause the documentation to be installed
in **${CMAKE\_INSTALL\_PREFIX}/doc**.)  If a directory variable contains the
name of another directory variable in angle brackets, then its final value will
depend on the final value of that other variable.  For instance, the default
value of `CMAKE_INSTALL_DOCDIR` is **\<CMAKE\_INSTALL\_DATAROOTDIR\>/doc**.


Creating Distribution Packages
==============================

Run

    make tarball

or

    make zip

to create a binary package containing the TurboJPEG/Java build.


Regression testing
==================

The most common way to test TurboJPEG/Java is by invoking `make test` (Un*x) or
`nmake test` (Windows command line) or by building the "RUN_TESTS" target
(Visual Studio IDE), once the build has completed.  This invokes the TurboJPEG
unit tests, which ensure that the colorspace extensions, YUV encoding,
decompression scaling, and other features of the TurboJPEG Java API are working
properly.

Invoking `make testclean` (Un*x) or `nmake testclean` (Windows command line) or
building the "testclean" target (Visual Studio IDE) will clean up the output
images generated by the tests.

On Un*x platforms, more extensive tests of TurboJPEG/Java can be run by
invoking `make tjtest`, `make tjtest12`, and `make tjtest16`.  These extended
TurboJPEG tests essentially iterate through all of the available features of
the TurboJPEG API that are not covered by the TurboJPEG unit tests (including
the lossless transform options) and compare the images generated by each
feature to images generated using the equivalent feature in the libjpeg API.

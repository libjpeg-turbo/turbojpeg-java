TurboJPEG/Java
==============

TurboJPEG/Java consists of a Java front end (the TurboJPEG Java API) and a Java
Native Interface (JNI) library that allow Java applications to access the
TurboJPEG C API indirectly.  The Java classes are located under
**org/libjpegturbo/turbojpeg**.  The source code for these classes and the
associated JNI library is licensed under a [BSD-style license](LICENSE.md), so
the files can be incorporated directly into both open source and proprietary
projects without restriction.

[TJComp.java](TJComp.java), [TJDecomp.java](TJDecomp.java), and
[TJTran.java](TJTran.java), which should be located in the same directory as
this README file, demonstrate how to use the TurboJPEG Java API to compress,
decompress, and transform JPEG images in memory.


Performance Pitfalls
--------------------

The TurboJPEG Java API defines convenience methods that can allocate image
buffers or instantiate classes to hold the result of compress, decompress, or
transform operations.  However, if you use these methods, then be mindful of
the amount of new data you are creating on the heap.  It may be necessary to
manually invoke the garbage collector to prevent heap exhaustion or to prevent
performance degradation.  Background garbage collection can kill performance,
particularly in a multi-threaded environment.  (Java pauses all threads when
the GC runs.)

The TurboJPEG Java API always gives you the option of pre-allocating your own
source and destination buffers, which allows you to re-use those buffers for
compressing/decompressing multiple images.  If the image sequence you are
compressing or decompressing consists of images of the same size, then
pre-allocating the buffers is recommended.


Installation Directory
----------------------

The TurboJPEG Java classes will look for the TurboJPEG JNI library
(**libturbojpeg-jni.so**, **libturbojpeg-jni.dylib**, or **turbojpeg-jni.dll**)
in the system library paths or in any paths specified in `LD_LIBRARY_PATH`
(Un\*x), `DYLD_LIBRARY_PATH` (Mac), `PATH` (Windows), or the
`java.library.path` Java system property.  Failing this, the classes will look
for the JNI library in the same directory as **turbojpeg.jar**.

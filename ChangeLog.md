3.2 Evolving
============

### Significant changes relative to 3.1.x

1. The JNI library loader in the TurboJPEG Java wrapper now looks for the
TurboJPEG JNI library in the same directory as **turbojpeg.jar** if it cannot
find it in the system library paths.

2. It should now be possible to use the TurboJPEG JNI library with older or
newer versions of the TurboJPEG API library than the version against which the
JNI library was built.


3.1.3
=====

### Significant changes relative to 3.1.2:

1. Hardened the TurboJPEG Java API against hypothetical applications that may
erroneously pass huge X or Y offsets to one of the compression, YUV encoding,
decompression, or YUV decoding methods, leading to signed integer overflow in
the JNI wrapper's buffer size checks that rendered those checks ineffective.

2. Fixed an issue in the TurboJPEG Java API whereby
`TJCompressor.getSourceBuf()` sometimes returned the buffer from a previous
invocation of `TJCompressor.loadSourceImage()` if the target data precision was
changed before the most recent invocation.


3.1.2
=====

### Significant changes relative to 3.1 beta1:

1. Fixed a regression introduced by 3.1 beta1[3] that caused a segfault in
TJBench if `-copy` or `-c` was passed as the last command-line argument.


3.0.90 (3.1 beta1)
==================

### Significant changes relative to 3.0.4:

1. Added support for lossless JPEG images with 2 to 15 bits per sample to the
TurboJPEG API.  When creating or decompressing a lossless JPEG image and when
loading or saving a PBMPLUS image, methods specific to 8-bit samples now handle
8-bit samples with 2 to 8 bits of data precision (specified using
`TJ.PARAM_PRECISION`), methods specific to 12-bit samples now handle 12-bit
samples with 9 to 12 bits of data precision, and methods specific to 16-bit
samples now handle 16-bit samples with 13 to 16 bits of data precision.  Refer
to the TurboJPEG API documentation for more details.

2. All deprecated constants and methods in the TurboJPEG Java API have been
removed.

3. TJBench command-line arguments are now more consistent with those of cjpeg,
djpeg, and jpegtran.  More specifically:

     - `-copynone` has been replaced with `-copy none`.
     - `-fastdct` has been replaced with `-dct fast`.
     - `-fastupsample` has been replaced with `-nosmooth`.
     - `-hflip` and `-vflip` have been replaced with
`-flip {horizontal|vertical}`.
     - `-limitscans` has been replaced with `-maxscans`, which allows the scan
limit to be specified.
     - `-rgb`, `-bgr`, `-rgbx`, `-bgrx`, `-xbgr`, `-xrgb`, and `-cmyk` have
been replaced with `-pixelformat {rgb|bgr|rgbx|bgrx|xbgr|xrgb|cmyk}`.
     - `-rot90`, `-rot180`, and `-rot270` have been replaced with
`-rotate {90|180|270}`.
     - `-stoponwarning` has been replaced with `-strict`.
     - British spellings for `gray` (`grey`) and `optimize` (`optimise`) are
now allowed.

    The old command-line arguments are deprecated and will be removed in a
future release.  TJBench command-line arguments can now be abbreviated as well.
(Where possible, the abbreviations are the same as those supported by cjpeg,
djpeg, and jpegtran.)

4. Added a new TJBench option (`-pixelformat gray`) that can be used to test
the performance of compressing/decompressing a grayscale JPEG image from/to a
packed-pixel grayscale image.

5. The TurboJPEG Java API has been improved in the following ways:

     - New image I/O methods (`TJCompressor.loadSourceImage()` and
`TJDecompressor.saveImage()`) have been added.  These methods work similarly to
the `tj3LoadImage*()` and `tj3SaveImage*()` functions in the C API.
     - The TurboJPEG lossless transformation methods now add restart markers to
all destination images if `TJ.PARAM_RESTARTBLOCKS` or `TJ.PARAM_RESTARTROWS` is
set.
     - New methods (`TJCompressor.setICCProfile()` /
`TJTransformer.setICCProfile()` and `TJDecompressor.getICCProfile()`) can be
used to embed and retrieve ICC profiles.
     - A new parameter (`TJ.PARAM_SAVEMARKERS`) can be used to specify the
types of markers that will be copied from the source image to the destination
image during lossless transformation if `TJTransform.OPT_COPYNONE` is not
specified.
     - A new convenience method (`TJTransformer.bufSize()`) can be used to
compute the worst-case destination buffer size for a given lossless transform,
taking into account cropping, transposition of the width and height, grayscale
conversion, and the embedded or extracted ICC profile.

6. TJExample has been replaced with three programs (TJComp, TJDecomp, and
TJTran) that demonstrate how to approximate the functionality of cjpeg, djpeg,
and jpegtran using the TurboJPEG Java API.


3.0.4
=====

### Significant changes relative to 3.0.2:

1. Fixed an error ("Destination buffer is not large enough") that occurred when
attempting to generate a full-color lossless JPEG image using the TurboJPEG
Java API's `byte[] TJCompressor.compress()` method if the value of
`TJ.PARAM_SUBSAMP` was not `TJ.SAMP_444`.

2. Fixed an issue whereby the TurboJPEG lossless transformation methods checked
the specified cropping region against the source image dimensions and level of
chrominance subsampling rather than the destination image dimensions and level
of chrominance subsampling, which caused some cropping regions to be unduly
rejected when performing 90-degree rotation, 270-degree rotation,
transposition, transverse transposition, or grayscale conversion.

3. Fixed an issue whereby the TurboJPEG lossless transformation methods did not
honor `TJTransform.OPT_COPYNONE` unless it was specified for all lossless
transforms.


3.0.2
=====

### Significant changes relative to 3.0.0:

1. Introduced a new parameter (`TJ.PARAM_MAXMEMORY`) in the TurboJPEG Java API
and a corresponding TJBench option (`-maxmemory`) for specifying the maximum
amount of memory (in megabytes) that will be allocated for intermediate
buffers, which are used with progressive JPEG compression and decompression,
Huffman table optimization, lossless JPEG compression, and lossless
transformation.  The new parameter and option serve the same purpose as the
`max_memory_to_use` field in the `jpeg_memory_mgr` struct in the libjpeg API,
the `JPEGMEM` environment variable, and the cjpeg/djpeg/jpegtran `-maxmemory`
option.

2. Introduced a new parameter (`TJ.PARAM_MAXPIXELS`) in the TurboJPEG Java API
and a corresponding TJBench option (`-maxpixels`) for specifying the maximum
number of pixels that the decompression, lossless transformation, and
packed-pixel image loading methods will process.


3.0.0
=====

### Significant changes relative to 3.0 beta2:

1. The TurboJPEG API now supports 4:4:1 (transposed 4:1:1) chrominance
subsampling, which allows losslessly transposed or rotated 4:1:1 JPEG images to
be losslessly cropped, partially decompressed, or decompressed to planar YUV
images.


2.1.91 (3.0 beta2)
==================

### Significant changes relative to 2.1.5:

1. All deprecated fields, constructors, and methods in the TurboJPEG Java API
have been removed.

2. Arithmetic entropy coding is now supported with 12-bit-per-component JPEG
images.

3. Overhauled the TurboJPEG API to address long-standing limitations and to
make the API more extensible and intuitive:

     - Stateless boolean flags have been replaced with stateful integer API
parameters, the values of which persist between function calls.  New methods
(`TJCompressor.set()`/`TJDecompressor.set()` and
`TJCompressor.get()`/`TJDecompressor.get()`) can be used to set and query the
value of a particular API parameter.
     - The JPEG quality and subsampling are now implemented using API
parameters rather than dedicated set/get methods.
     - `TJ.FLAG_LIMITSCANS` has been reimplemented as an API parameter
(`TJ.PARAM_SCANLIMIT`) that allows the number of scans to be specified.
     - Huffman table optimization can now be specified using a new API
parameter (`TJ.PARAM_OPTIMIZE`), a new transform option
(`TJTransform.OPT_OPTIMIZE`), and a new TJBench option (`-optimize`.)
     - Arithmetic entropy coding can now be specified or queried, using a new
API parameter (`TJ.PARAM_ARITHMETIC`), a new transform option
(`TJTransform.OPT_ARITHMETIC`), and a new TJBench option (`-arithmetic`.)
     - The restart marker interval can now be specified, using new API
parameters (`TJ.PARAM_RESTARTROWS` and `TJ.PARAM_RESTARTBLOCKS`) and a new
TJBench option (`-restart`.)
     - Pixel density can now be specified or queried, using new API parameters
(`TJ.PARAM_XDENSITY`, ``TJ.PARAM_YDENSITY`, and `TJ.PARAM_DENSITYUNITS`.)
     - The accurate DCT/IDCT algorithms are now the default for both
compression and decompression, since the "fast" algorithms are considered to be
a legacy feature.  (The "fast" algorithms do not pass the ISO compliance tests,
and those algorithms are not any faster than the accurate algorithms on modern
x86 CPUs.)
     - Decompression scaling is now enabled explicitly, using a new
method (`TJDecompressor.setScalingFactor()`), rather than implicitly using
awkward "desired width"/"desired height" arguments.
     - Partial image decompression has been implemented, using a new
method (`TJDecompressor.setCroppingRegion()`) and a new TJBench option
(`-crop`.)
     - The JPEG colorspace can now be specified explicitly when compressing,
using a new API parameter (`TJ.PARAM_COLORSPACE`.)  This allows JPEG images
with the RGB and CMYK colorspaces to be created.
     - TJBench no longer generates error/difference images, since identical
functionality is already available in ImageMagick.
     - JPEG images with unknown subsampling configurations can now be
fully decompressed into packed-pixel images or losslessly transformed (with the
exception of lossless cropping.)  They cannot currently be partially
decompressed or decompressed into planar YUV images.

4. Added support for 8-bit-per-component, 12-bit-per-component, and
16-bit-per-component lossless JPEG images.  New TurboJPEG API parameters
(`TJ.PARAM_LOSSLESS`, `TJ.PARAM_LOSSLESSPSV`, and `TJ.PARAM_LOSSLESSPT`), and a
TJBench option (`-lossless`) can be used to create a lossless JPEG image.
(Decompression of lossless JPEG images is handled automatically.)  Refer to the
TurboJPEG API documentation for more details.

5. Added support for 12-bit-per-component (lossy and lossless) and
16-bit-per-component (lossless) JPEG images to the libjpeg and TurboJPEG APIs:

     - New 12-bit-per-component and 16-bit-per-component compression,
decompression, and image I/O methods have been added to the TurboJPEG API, and
a new API parameter (`TJ.PARAM_PRECISION`) can be used to query the data
precision of a JPEG image.  (YUV functions are currently limited to 8-bit data
precision but can be expanded to accommodate 12-bit data precision in the
future, if such is deemed beneficial.)
     - A new TJBench command-line argument (`-precision`) can be used to create
a 12-bit-per-component or 16-bit-per-component JPEG image.  (Decompression and
transformation of 12-bit-per-component and 16-bit-per-component JPEG images is
handled automatically.)

    Refer to the TurboJPEG API documentation for more details.


2.1.5
=====

### Significant changes relative to 2.1.4:

1. Fixed an issue whereby the Java version of TJBench did not accept a range of
quality values.

2. Fixed an issue whereby, when `-progressive` was passed to TJBench, the JPEG
input image was not transformed into a progressive JPEG image prior to
decompression.


2.1.4
=====

### Significant changes relative to 2.1.0:

1. The `TJDecompressor.setSourceImage()` method in the TurboJPEG Java API now
accepts "abbreviated table specification" (AKA "tables-only") datastreams,
which can be used to prime the decompressor with quantization and Huffman
tables that can be used when decompressing subsequent "abbreviated image"
datastreams.


2.1.0
=====

### Significant changes relative to 2.0.6:

1. Introduced a new flag (`TJ.FLAG_LIMIT_SCANS`) in the TurboJPEG Java API and
a corresponding TJBench command-line argument (`-limitscans`) that causes the
TurboJPEG decompression and transform operations to throw an error if a
progressive JPEG image contains an unreasonably large number of scans.  This
allows applications that use the TurboJPEG API to guard against an exploit of
the progressive JPEG format described in the report
["Two Issues with the JPEG Standard"](https://libjpeg-turbo.org/pmwiki/uploads/About/TwoIssueswiththeJPEGStandard.pdf).


2.0.6
=====

### Significant changes relative to 2.0.5:

1. Fixed "using JNI after critical get" errors that occurred on Android
platforms when using any of the YUV encoding/compression/decompression/decoding
methods in the TurboJPEG Java API.


2.0.5
=====

### Significant changes relative to 2.0.3:

1. Fixed an oversight in the `TJCompressor.compress(int)` method in the
TurboJPEG Java API that caused an error ("java.lang.IllegalStateException: No
source image is associated with this instance") when attempting to use that
method to compress a YUV image.


2.0.3
=====

### Significant changes relative to 2.0 beta1:

1. Fixed "using JNI after critical get" errors that occurred on Android
platforms when passing invalid arguments to certain methods in the TurboJPEG
Java API.

2. Fixed an integer overflow and subsequent segfault (CVE-2019-2201) that
occurred when attempting to compress or decompress images with more than 1
billion pixels using the TurboJPEG API.


1.5.90 (2.0 beta1)
==================

### Significant changes relative to 1.5.3:

1. Improved error handling in the TurboJPEG Java API:

     - Introduced a new method (`TJException.getErrorCode()`) that can be used
to determine the severity of the last compression/decompression/transform
error.  This allows applications to choose whether to ignore warnings
(non-fatal errors) from the underlying libjpeg API or to treat them as fatal.
     - Introduced a new flag (`TJ.FLAG_STOPONWARNING`) that causes the library
to immediately halt a compression/decompression/transform operation if it
encounters a warning from the underlying libjpeg API (the default behavior is
to allow the operation to complete unless a fatal error is encountered.)

2. Introduced a new flag in the TurboJPEG Java API (`TJ.FLAG_PROGRESSIVE`) that
causes compression and transform operations to generate progressive JPEG
images.  Additionally, a new transform option (`TJTransform.OPT_PROGRESSIVE`)
has been introduced, allowing progressive JPEG images to be generated by
selected transforms in a multi-transform operation.

3. Introduced a new transform option in the TurboJPEG Java API
(`TJTransform.OPT_COPYNONE`) that allows the copying of markers (including Exif
and ICC profile data) to be disabled for a particular transform.

4. The TurboJPEG Java API now includes a new method (`TJ.getAlphaOffset()`)
that returns the alpha component index for a particular pixel format (or -1 if
the pixel format lacks an alpha component.)  In addition, the
`TJ.getRedOffset()`, `TJ.getGreenOffset()`, and `TJ.getBlueOffset()` methods
now return -1 for `TJ.PF_GRAY` rather than 0.  This allows programs to easily
determine whether a pixel format has red, green, blue, and alpha components.


1.5.3
=====

### Significant changes relative to 1.5.2:

1. Fixed a NullPointerException in the TurboJPEG Java wrapper that occurred
when using the YUVImage constructor that creates an instance backed by separate
image planes and allocates memory for the image planes.

2. Fixed an issue whereby the Java version of TJUnitTest would fail when
testing BufferedImage encoding/decoding on big endian systems.

3. TJBench will now display usage information if any command-line argument is
unrecognized.  This prevents the program from silently ignoring typos.


1.5.2
=====

### Significant changes relative to 1.5 beta1:

1. Fixed a regression introduced by 1.5 beta1[3] that prevented the Java
version of TJBench from outputting any reference images (the `-nowrite` switch
was accidentally enabled by default.)

2. TJBench will now run each benchmark for 1 second prior to starting the
timer, in order to improve the consistency of the results.  Furthermore, the
`-warmup` option is now used to specify the amount of warmup time rather than
the number of warmup iterations.


1.4.90 (1.5 beta1)
==================

### Significant changes relative to 1.4.0:

1. The TJCompressor and TJDecompressor classes in the TurboJPEG Java API now
implement the Closeable interface, so those classes can be used with a
try-with-resources statement.

2. The TurboJPEG Java classes now throw unchecked idiomatic exceptions
(IllegalArgumentException, IllegalStateException) for unrecoverable errors
caused by incorrect API usage, and those classes throw a new checked exception
type (TJException) for errors that are passed through from the C library.

3. Added a new command-line argument to TJBench (`-nowrite`) that prevents the
benchmark from outputting any images.  This removes any potential operating
system overhead that might be caused by lazy writes to disk and thus improves
the consistency of the performance measurements.


1.4.0
=====

### Significant changes relative to 1.4 beta1:

1. The `close()` method in the TJCompressor and TJDecompressor Java classes is
now idempotent.  Previously, that method would call the native `tjDestroy()`
function even if the TurboJPEG instance had already been destroyed.  This
caused an exception to be thrown during finalization, if the `close()` method
had already been called.  The exception was caught, but it was still an
expensive operation.


1.3.90 (1.4 beta1)
==================

### Significant changes relative to 1.3 beta1:

1. New features in the TurboJPEG API:

     - YUV planar images can now be generated with an arbitrary line padding
(previously only 4-byte padding, which was compatible with X Video, was
supported.)
     - The decompress-to-YUV function has been extended to support image
scaling.
     - JPEG images can now be compressed from YUV planar source images.
     - YUV planar images can now be decoded into RGB or grayscale images.
     - 4:1:1 subsampling is now supported.  This is mainly included for
compatibility, since 4:1:1 is not fully accelerated in libjpeg-turbo and has no
significant advantages relative to 4:2:0.
     - CMYK images are now supported.  This feature allows CMYK source images
to be compressed to YCCK JPEGs and YCCK or CMYK JPEGs to be decompressed to
CMYK destination images.  Conversion between CMYK/YCCK and RGB or YUV images is
not supported.  Such conversion requires a color management system and is thus
out of scope for a codec library.
     - The handling of YUV images in the Java API has been significantly
refactored and should now be much more intuitive.
     - The Java API now supports encoding a YUV image from an arbitrary
position in a large image buffer.
     - All of the YUV functions now have a corresponding function that operates
on separate image planes instead of a unified image buffer.  This allows for
compressing/decoding from or decompressing/encoding to a subregion of a larger
YUV image.  It also allows for handling YUV formats that swap the order of the
U and V planes.


1.2.90 (1.3 beta1)
==================

### Significant changes relative to 1.2.1:

1. Extended the TurboJPEG Java API so that it can be used to compress a JPEG
image from and decompress a JPEG image to an arbitrary position in a large
image buffer.

2. TJBench has been ported to Java to provide a convenient way of validating
the performance of the TurboJPEG Java API.  It can be run with
`java -cp turbojpeg.jar TJBench`.


1.2.1
=====

### Significant changes relative to 1.2.0:

1. Added flags to the TurboJPEG API that allow the caller to force the use of
either the fast or the accurate DCT/IDCT algorithms in the underlying codec.


1.2.0
=====

### Significant changes relative to 1.2 beta1:

1. Added new RGBA/BGRA/ABGR/ARGB pixel formats (TurboJPEG API), which allow
applications to specify that, when decompressing to a 4-component RGB buffer,
the unused byte should be set to 0xFF so that it can be interpreted as an
opaque alpha channel.


1.1.90 (1.2 beta1)
==================

1. Added a Java wrapper for the TurboJPEG API.  See [README.md](README.md) for
more details.

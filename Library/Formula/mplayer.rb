class Mplayer < Formula
  desc "UNIX movie player"
  homepage "https://mplayerhq.hu/"

  stable do
    url "https://mplayerhq.hu/MPlayer/releases/MPlayer-1.5.tar.xz"
    sha256 "650cd55bb3cb44c9b39ce36dac488428559799c5f18d16d98edb2b7256cbbf85"
  end

  bottle do
  end

  head do
    url "svn://svn.mplayerhq.hu/mplayer/trunk"
    depends_on "subversion" => :build
  end

  # Needs atomic such as sync_bool_compare_and_swap
  fails_with :gcc_4_0

  # When building SVN, configure prompts the user to pull FFmpeg from git.
  # help with find OpenGL on Tiger
  # https://raw.githubusercontent.com/macports/macports-ports/cb7a1cc812a77dfbcd06dcd56e646bb4497d0454/multimedia/MPlayer/files/patch-libvo-osx-objc-common-opengl-headers.diff
  # argument 1 must be a 5-bit signed literal
  patch :p0, :DATA

  option "without-osd", "Build without OSD"

  # dupe make needed because of "make: *** virtual memory exhausted.  Stop."
  depends_on "make" => :build if MacOS.version < :leopard
  depends_on "yasm" => :build
  depends_on "libcaca" => :optional
  depends_on "pkg-config" => :build
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "fribidi"
  depends_on "a52dec"
  depends_on "libxml2"
  depends_on "openssl3"
  depends_on "giflib"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "mad"
  depends_on "lzo"
  depends_on "bzip2"
  depends_on "libmpeg2"
  depends_on "libvorbis"
  depends_on "libogg"
  depends_on "theora"
  depends_on "faad2"
  depends_on "zlib"

  def install
    # Build probes & sets its own optimisation
    ENV.no_optimization

    # we may empty our cflags, but skipping -faltivec is bad news on Tiger
    ENV.append_to_cflags '-faltivec' if MacOS.version == :tiger

    # we disable cdparanoia because homebrew's version is hacked to work on OS X
    # and mplayer doesn't expect the hacks we apply. So it chokes. Only relevant
    # if you have cdparanoia installed.
    # Specify our compiler to stop ffmpeg from defaulting to gcc.
    args = %W[
      --cc=#{ENV.cc}
      --host-cc=#{ENV.cc}
      --disable-cdparanoia
      --prefix=#{prefix}
      --disable-x11
      --enable-apple-remote
      --enable-openssl-nondistributable
    ]

    args << "--enable-caca" if build.with? "libcaca"
    args << "--extra-libs-mencoder=-framework Carbon" if MacOS.version < :snow_leopard

    # bytestream2_put_be16 & bytestream2_put_byte unimplemented
    args << "--disable-encoder=sgi" if Hardware.cpu_type == :ppc

    system "./configure", *args
    system make_path
    system make_path, "install"
  end

  test do
    system "#{bin}/mplayer", "-ao", "null", "/System/Library/Sounds/Glass.aiff"
  end
end

__END__
--- configure
+++ configure
@@ -1532,8 +1532,6 @@
 fi
 
 if test "$ffmpeg_a" != "no" && ! test -e ffmpeg ; then
-    echo "No FFmpeg checkout, press enter to download one with git or CTRL+C to abort"
-    read tmp
     if ! git clone -b $FFBRANCH --depth 1 git://source.ffmpeg.org/ffmpeg.git ffmpeg ; then
         rm -rf ffmpeg
         echo "Failed to get a FFmpeg checkout"
--- libvo/osx_objc_common.m.orig	2017-08-13 10:10:39.000000000 -0700
+++ libvo/osx_objc_common.m	2017-08-13 10:52:06.000000000 -0700
@@ -29,6 +29,22 @@
 #include <CoreServices/../Frameworks/OSServices.framework/Headers/Power.h>
 #endif
 
+#ifdef __APPLE__
+# ifndef __MAC_OS_X_VERSION_MIN_REQUIRED
+#  if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050
+#   include <Availability.h>
+#  else
+#   include <AvailabilityMacros.h>
+#  endif
+# endif
+#endif
+
+#if __MAC_OS_X_VERSION_MIN_REQUIRED < 1050
+# include <OpenGL/gl.h>
+# include <OpenGL/glu.h>
+# include <GLUT/glut.h>
+#endif
+
 //MPLAYER
 #include "config.h"
 #include "video_out.h"
--- ffmpeg/libswscale/ppc/swscale_altivec.c.orig	2024-05-13 21:32:04.000000000 +0100
+++ ffmpeg/libswscale/ppc/swscale_altivec.c	2024-05-13 21:34:55.000000000 +0100
@@ -107,6 +107,8 @@
 
 #endif /* HAVE_BIGENDIAN */
 
+#define SHIFT  3
+
 #define output_pixel(pos, val, bias, signedness) \
     if (big_endian) { \
         AV_WB16(pos, bias + av_clip_ ## signedness ## 16(val >> shift)); \
@@ -149,12 +151,11 @@
 static void yuv2plane1_float_altivec(const int32_t *src, float *dest, int dstW)
 {
     const int dst_u = -(uintptr_t)dest & 3;
-    const int shift = 3;
-    const int add = (1 << (shift - 1));
+    const int add = (1 << (SHIFT - 1));
     const int clip = (1 << 16) - 1;
     const float fmult = 1.0f / 65535.0f;
     const vec_u32 vadd = (vec_u32) {add, add, add, add};
-    const vec_u32 vshift = (vec_u32) vec_splat_u32(shift);
+    const vec_u32 vshift = (vec_u32) vec_splat_u32(SHIFT);
     const vec_u32 vlargest = (vec_u32) {clip, clip, clip, clip};
     const vec_f vmul = (vec_f) {fmult, fmult, fmult, fmult};
     const vec_f vzero = (vec_f) {0, 0, 0, 0};
@@ -182,12 +183,11 @@
 static void yuv2plane1_float_bswap_altivec(const int32_t *src, uint32_t *dest, int dstW)
 {
     const int dst_u = -(uintptr_t)dest & 3;
-    const int shift = 3;
-    const int add = (1 << (shift - 1));
+    const int add = (1 << (SHIFT - 1));
     const int clip = (1 << 16) - 1;
     const float fmult = 1.0f / 65535.0f;
     const vec_u32 vadd = (vec_u32) {add, add, add, add};
-    const vec_u32 vshift = (vec_u32) vec_splat_u32(shift);
+    const vec_u32 vshift = (vec_u32) vec_splat_u32(SHIFT);
     const vec_u32 vlargest = (vec_u32) {clip, clip, clip, clip};
     const vec_f vmul = (vec_f) {fmult, fmult, fmult, fmult};
     const vec_f vzero = (vec_f) {0, 0, 0, 0};

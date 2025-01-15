class PilotLink < Formula
  desc "That UNIX'y glue for your Palm handheld device"
  homepage "https://web.archive.org/web/20160226115446/http://www.pilot-link.org/"
  url "https://geeklan.co.uk/files/pilot-link-0.12.5.tar.bz2"
  mirror "https://mirrors.slackware.com/slackware/slackware/source/l/pilot-link/pilot-link-0.12.5.tar.bz2"
  version "0.12.5"
  sha256 "d3f99ec04016b38995fb370265200254710318105c792c017d3aaccfb97a84b2"

  depends_on "pkg-config" => :build
  depends_on "libusb-compat"
  depends_on "libpng"
  depends_on "popt"
  depends_on "readline"

  # Fix compatibility with libpng 1.4 & newer.
  # https://mirrors.slackware.com/slackware/slackware/source/l/pilot-link/pilot-link.png14.diff.gz
  patch :p0, :DATA

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--enable-conduits",
                          "--enable-libusb",
                          "--enable-threads",
                          "--with-libpng",
                          "--with-pic"
    system "make"
    system "make", "install"
    system "make", "-C", "doc/man", "install"
  end

  def caveats; <<-EOS.undent
    For a list of installed utilites and how to connect to your PDA,
    see the pilot-link(7) manual installed at
    #{man}/man7/pilot-link.7
    EOS
  end

end
__END__
--- ./src/pilot-read-veo.c.orig	2007-02-04 17:06:03.000000000 -0600
+++ ./src/pilot-read-veo.c	2010-02-19 12:52:30.000000000 -0600
@@ -41,10 +41,6 @@
 
 #ifdef HAVE_PNG
 # include "png.h"
-# if (PNG_LIBPNG_VER < 10201)
-#  define png_voidp_NULL (png_voidp)NULL
-#  define png_error_ptr_NULL (png_error_ptr)NULL
-# endif
 #endif
 
 #define pi_mktag(c1,c2,c3,c4) (((c1)<<24)|((c2)<<16)|((c3)<<8)|(c4))
@@ -856,8 +852,8 @@
    png_infop info_ptr;
 
    png_ptr = png_create_write_struct
-	 (PNG_LIBPNG_VER_STRING, png_voidp_NULL,
-	  png_error_ptr_NULL, png_error_ptr_NULL);
+	 (PNG_LIBPNG_VER_STRING, NULL,
+	  NULL, NULL);
 
    if (!png_ptr)
 	 return;
--- ./src/pilot-read-notepad.c.orig	2007-02-04 17:06:02.000000000 -0600
+++ ./src/pilot-read-notepad.c	2010-02-19 12:53:03.000000000 -0600
@@ -39,10 +39,6 @@
 
 #ifdef HAVE_PNG
 #include "png.h"
-#if (PNG_LIBPNG_VER < 10201)
- #define png_voidp_NULL (png_voidp)NULL
- #define png_error_ptr_NULL (png_error_ptr)NULL
-#endif
 #endif
 
 const char *progname;
@@ -166,8 +162,8 @@
    width = n->body.width + 8;
 
    png_ptr = png_create_write_struct
-     ( PNG_LIBPNG_VER_STRING, png_voidp_NULL,
-       png_error_ptr_NULL, png_error_ptr_NULL);
+     ( PNG_LIBPNG_VER_STRING, NULL,
+       NULL, NULL);
 
    if(!png_ptr)
      return;
--- ./src/pilot-read-screenshot.c.orig	2006-11-02 08:54:31.000000000 -0600
+++ ./src/pilot-read-screenshot.c	2010-02-19 12:50:44.000000000 -0600
@@ -40,10 +40,6 @@
 
 #ifdef HAVE_PNG
 # include "png.h"
-# if (PNG_LIBPNG_VER < 10201)
-#  define png_voidp_NULL (png_voidp)NULL
-#  define png_error_ptr_NULL (png_error_ptr)NULL
-# endif
 #endif
 
 #define pi_mktag(c1,c2,c3,c4) (((c1)<<24)|((c2)<<16)|((c3)<<8)|(c4))
@@ -87,8 +83,8 @@
 		gray_buf = malloc( state->w );
 
 	png_ptr = png_create_write_struct
-		(PNG_LIBPNG_VER_STRING, png_voidp_NULL,
-		png_error_ptr_NULL, png_error_ptr_NULL);
+		(PNG_LIBPNG_VER_STRING, NULL,
+		NULL, NULL);
 
 	if (!png_ptr)
 		return;
--- ./src/pilot-read-palmpix.c.orig	2007-02-04 17:06:03.000000000 -0600
+++ ./src/pilot-read-palmpix.c	2010-02-19 12:51:10.000000000 -0600
@@ -42,10 +42,6 @@
 
 #ifdef HAVE_PNG
 #include "png.h"
-#if (PNG_LIBPNG_VER < 10201)
- #define png_voidp_NULL (png_voidp)NULL
- #define png_error_ptr_NULL (png_error_ptr)NULL
-#endif
 #endif
 
 const char *progname;
@@ -223,8 +219,8 @@
 	png_infop info_ptr;
 
 	png_ptr = png_create_write_struct
-		( PNG_LIBPNG_VER_STRING, png_voidp_NULL,
-		png_error_ptr_NULL, png_error_ptr_NULL);
+		( PNG_LIBPNG_VER_STRING, NULL,
+		NULL, NULL);
 
 	if(!png_ptr)
 		return;


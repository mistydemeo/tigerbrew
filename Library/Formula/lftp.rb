class Lftp < Formula
  desc "Sophisticated file transfer program"
  homepage "http://lftp.yar.ru/"
  url "http://lftp.yar.ru/ftp/lftp-4.9.2.tar.xz"
  sha256 "c517c4f4f9c39bd415d7313088a2b1e313b2d386867fe40b7692b83a20f0670d"

  bottle do
  end

  # step past a gnulib issue
  patch :p0, :DATA

  depends_on "pkg-config" => :build
  depends_on "bison"
  depends_on "expat"
  depends_on "libidn2"
  depends_on "readline"
  depends_on "openssl3"
  depends_on "zlib"

  needs :cxx11

  def install
    ENV.cxx11

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-zlib=#{Formula["zlib"].opt_prefix}",
                          "--with-expat=#{Formula["expat"].opt_prefix}",
                          "--with-readline=#{Formula["readline"].opt_prefix}",
                          "--with-openssl=#{Formula["openssl3"].opt_prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/lftp", "-c", "open https://ftp.gnu.org/; ls"
  end
end
__END__
--- lib/libc-config.h.orig	2024-05-15 23:07:30.000000000 +0100
+++ lib/libc-config.h	2024-05-15 23:09:32.000000000 +0100
@@ -83,9 +83,11 @@
    nonexistent files.  Make it a syntax error, since Gnulib does not
    use __WORDSIZE now, and if Gnulib uses it later the syntax error
    will let us know that __WORDSIZE needs configuring.  */
+/*
 #ifndef __WORDSIZE
 # define __WORDSIZE %%%
 #endif
+*/
 /* Undef the macros unconditionally defined by our copy of glibc
    <sys/cdefs.h>, so that they do not clash with any system-defined
    versions.  */
--- lib/cdefs.h.orig	2024-05-15 23:09:39.000000000 +0100
+++ lib/cdefs.h	2024-05-15 23:09:55.000000000 +0100
@@ -473,10 +473,12 @@
 
 /* The #ifndef lets Gnulib avoid including these on non-glibc
    platforms, where the includes typically do not exist.  */
+/*
 #ifndef __WORDSIZE
 # include <bits/wordsize.h>
 # include <bits/long-double.h>
 #endif
+*/
 
 #if defined __LONG_DOUBLE_MATH_OPTIONAL && defined __NO_LONG_DOUBLE_MATH
 # define __LDBL_COMPAT 1

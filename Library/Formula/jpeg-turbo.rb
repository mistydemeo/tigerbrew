require 'formula'

class JpegTurbo < Formula
  homepage 'http://www.libjpeg-turbo.org/'
  url 'https://downloads.sourceforge.net/project/libjpeg-turbo/1.3.1/libjpeg-turbo-1.3.1.tar.gz'
  mirror 'https://mirrors.kernel.org/debian/pool/main/libj/libjpeg-turbo/libjpeg-turbo_1.3.1.orig.tar.gz'
  sha1 '5fa19252e5ca992cfa40446a0210ceff55fbe468'

  bottle do
    cellar :any
    sha1 "d3bd70ed5eb4beecc84c782f69e2376915e978cc" => :yosemite
    sha1 "d9456e1ae7d99dd88e7c7a0b34c52408f0d02f6a" => :mavericks
    sha1 "9e7bd8532480479cd4011fa263c65b860e6d6928" => :mountain_lion
  end

  depends_on "libtool" => :build
  depends_on 'nasm' => :build if MacOS.prefer_64_bit?

  keg_only "libjpeg-turbo is not linked to prevent conflicts with the standard libjpeg."

  # Big-endian code in md5.c uses byteswapping functions that only exist on
  # Linux; this defines macros to replace them with their OS X equivalents.
  # https://github.com/mistydemeo/tigerbrew/issues/76
  # Submitted upstream: https://sourceforge.net/p/libjpeg-turbo/patches/65/
  patch :DATA

  def install
    cp Dir["#{Formula["libtool"].opt_share}/libtool/*/config.{guess,sub}"], buildpath
    args = ["--disable-dependency-tracking", "--prefix=#{prefix}", "--with-jpeg8", "--mandir=#{man}"]
    if MacOS.prefer_64_bit?
      # Auto-detect our 64-bit nasm
      args << "NASM=#{Formula["nasm"].bin}/nasm"
    end

    system "./configure", *args
    system 'make'
    ENV.j1 # Stops a race condition error: file exists
    system "make install"
  end

  test do
    system "#{bin}/jpegtran", "-crop", "1x1",
                              "-transpose", "-perfect",
                              "-outfile", "out.jpg",
                              test_fixtures("test.jpg")
  end
end

__END__
diff --git a/md5/md5.c b/md5/md5.c
index 7193e95..6ef2023 100644
--- a/md5/md5.c
+++ b/md5/md5.c
@@ -38,6 +38,12 @@ static void MD5Transform(unsigned int [4], const unsigned char [64]);
 #define Decode memcpy
 #else 
 
+#ifdef __APPLE__
+#include <libkern/OSByteOrder.h>
+#define le32toh(x) OSSwapLittleToHostInt32(x)
+#define htole32(x) OSSwapHostToLittleInt32(x)
+#endif
+
 /*
  * Encodes input (unsigned int) into output (unsigned char). Assumes len is
  * a multiple of 4.

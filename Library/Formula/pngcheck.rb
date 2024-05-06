class Pngcheck < Formula
  desc "Print info and check PNG, JNG, and MNG files"
  homepage "http://www.libpng.org/pub/png/apps/pngcheck.html"
  url "http://www.libpng.org/pub/png/src/pngcheck-3.0.3.tar.gz"
  sha256 "c36a4491634af751f7798ea421321642f9590faa032eccb0dd5fb4533609dee6"

  bottle do
    cellar :any
    sha256 "769af0721d855771c53d5a3c28dbbf203515fef675594db154c885885a364387" => :tiger_altivec
  end

  # Allow the compiler to be built with & zlib to use to be specified
  patch :p0, :DATA

  depends_on "zlib"

  def install
    system "make", "-f", "Makefile.unx", "ZPATH=#{Formula["zlib"].opt_prefix}"
    bin.install %w[pngcheck pngsplit png-fix-IDAT-windowsize]
  end

  test do
    system bin/"pngcheck", test_fixtures("test.png")
  end
end
__END__
--- Makefile.unx.orig	2024-04-04 18:38:57.000000000 +0100
+++ Makefile.unx	2024-04-04 18:47:45.000000000 +0100
@@ -18,16 +18,16 @@
 
 # macros --------------------------------------------------------------------
 
-ZPATH = ../zlib
-ZINC = -I$(ZPATH)
-ZLIB = -L$(ZPATH) -lz
+ZPATH ?= ../zlib
+ZINC = -I$(ZPATH)/include
+ZLIB = -L$(ZPATH)/lib -lz
 #ZLIB = $(ZPATH)/libz.a
 
 INCS = $(ZINC)
 LIBS = $(ZLIB)
 
-CC = gcc
-LD = gcc
+CC ?= cc
+LD ?= cc
 RM = rm
 CFLAGS = -O -Wall $(INCS) -DUSE_ZLIB
 # [note that -Wall is a gcc-specific compilation flag ("all warnings on")]

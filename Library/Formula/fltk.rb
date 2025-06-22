class Fltk < Formula
  desc "Cross-platform C++ GUI toolkit"
  homepage "https://www.fltk.org/"
  url "https://github.com/fltk/fltk/releases/download/release-1.3.11/fltk-1.3.11-macOS10.11-source.tar.gz"
  sha256 "0dac140238bf6c0421b3877df5adb45a916d461cf8fc2c82523739ab08870149"

  bottle do
    sha256 "532b32269354d7eccc453cf8ad52a7f953f08986b6d87988f3c81649db251d79" => :tiger_altivec
  end

  option :universal

  depends_on "libpng"
  depends_on "jpeg"
  depends_on "zlib"

  # Fixes issue with -lpng not found.
  # Based on: https://trac.macports.org/browser/trunk/dports/aqua/fltk/files/patch-src-Makefile.diff
  patch :p0, :DATA

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}",
                          "--enable-threads",
                          "--enable-shared"
    system "make", "install"
  end
end

__END__
--- src/Makefile.orig	2023-12-09 13:58:40.000000000 +0000
+++ src/Makefile	2024-05-05 12:54:44.000000000 +0100
@@ -361,7 +361,7 @@
 		-install_name $(libdir)/$@ \
 		-current_version $(FL_VERSION) \
 		-compatibility_version $(FL_ABI_VERSION) \
-		$(IMGOBJECTS)  -L. $(LDLIBS) $(IMAGELIBS) -lfltk
+		$(IMGOBJECTS)  -L. $(LDLIBS) $(IMAGELIBS) -lfltk $(LDFLAGS)
 	$(RM) libfltk_images.dylib
 	$(LN) libfltk_images.$(FL_DSO_VERSION).dylib libfltk_images.dylib
 

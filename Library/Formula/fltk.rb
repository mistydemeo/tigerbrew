class Fltk < Formula
  desc "Cross-platform C++ GUI toolkit"
  homepage "http://www.fltk.org/"
  url "https://www.fltk.org/pub/fltk/1.3.9/fltk-1.3.9-source.tar.bz2"
  sha256 "103441134915402808fd45424d4061778609437e804334434e946cfd26b196c2"

  bottle do
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
 

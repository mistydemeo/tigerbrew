class Utf8proc < Formula
  desc "Clean C library for processing UTF-8 Unicode data"
  homepage "https://juliastrings.github.io/utf8proc/"
  url "https://github.com/JuliaStrings/utf8proc/releases/download/v2.9.0/utf8proc-2.9.0.tar.gz"
  sha256 "bd215d04313b5bc42c1abedbcb0a6574667e31acee1085543a232204e36384c4"
  license all_of: ["MIT", "Unicode-DFS-2015"]

  bottle do
    cellar :any
    sha256 "259035346607c349dac583c42df226ee6d3d84f32b9bfdbc564d304c3ccc7d3c" => :tiger_altivec
  end

  # Unbreak build on legacy compilers which lack warnings for sign conversion & linking
  patch :p0, :DATA

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <utf8proc.h>

      int main() {
        printf("%s", utf8proc_version());
      }
    EOS

    system ENV.cc, "test.c", "-std=c99", "-I#{include}", "-L#{lib}", "-lutf8proc", "-o", "test"
    system "./test"
  end
end
__END__
--- Makefile.orig	2023-12-01 17:22:03.000000000 +0000
+++ Makefile	2023-12-01 17:23:57.000000000 +0000
@@ -11,7 +11,7 @@
 CFLAGS ?= -O2
 PICFLAG = -fPIC
 C99FLAG = -std=c99
-WCFLAGS = -Wsign-conversion -Wall -Wextra -pedantic
+WCFLAGS = -Wall -Wextra -pedantic
 UCFLAGS = $(CPPFLAGS) $(CFLAGS) $(PICFLAG) $(C99FLAG) $(WCFLAGS) -DUTF8PROC_EXPORTS $(UTF8PROC_DEFINES)
 LDFLAG_SHARED = -shared
 SOFLAG = -Wl,-soname
@@ -92,7 +92,7 @@
 	ln -f -s libutf8proc.so.$(MAJOR).$(MINOR).$(PATCH) $@.$(MAJOR)
 
 libutf8proc.$(MAJOR).dylib: utf8proc.o
-	$(CC) $(LDFLAGS) -dynamiclib -o $@ $^ -install_name $(libdir)/$@ -Wl,-compatibility_version -Wl,$(MAJOR) -Wl,-current_version -Wl,$(MAJOR).$(MINOR).$(PATCH)
+	$(CC) $(LDFLAGS) -dynamiclib -o $@ $^ -install_name $(libdir)/$@ -compatibility_version $(MAJOR) -current_version $(MAJOR).$(MINOR).$(PATCH)
 
 libutf8proc.dylib: libutf8proc.$(MAJOR).dylib
 	ln -f -s libutf8proc.$(MAJOR).dylib $@

class Utf8proc < Formula
  desc "Clean C library for processing UTF-8 Unicode data"
  homepage "https://juliastrings.github.io/utf8proc/"
  url "https://github.com/JuliaStrings/utf8proc/archive/v2.8.0.tar.gz"
  sha256 "a0a60a79fe6f6d54e7d411facbfcc867a6e198608f2cd992490e46f04b1bcecc"
  license all_of: ["MIT", "Unicode-DFS-2015"]

  # Unbreak build on legacy compilers which lack warnings for sign conversion
  patch :p0, :DATA

  # Uses -compatibility_version, not present in Tiger
  depends_on :ld64

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
--- Makefile.orig	2023-07-21 01:44:12.000000000 +0100
+++ Makefile	2023-07-21 01:44:32.000000000 +0100
@@ -11,7 +11,7 @@
 CFLAGS ?= -O2
 PICFLAG = -fPIC
 C99FLAG = -std=c99
-WCFLAGS = -Wsign-conversion -Wall -Wextra -pedantic
+WCFLAGS = -Wall -Wextra -pedantic
 UCFLAGS = $(CPPFLAGS) $(CFLAGS) $(PICFLAG) $(C99FLAG) $(WCFLAGS) -DUTF8PROC_EXPORTS $(UTF8PROC_DEFINES)
 LDFLAG_SHARED = -shared
 SOFLAG = -Wl,-soname

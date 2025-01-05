require "formula"

class Newlisp < Formula
  desc "Lisp-like, general-purpose scripting language"
  homepage "http://www.newlisp.org/"
  url "http://www.newlisp.org/downloads/newlisp-10.7.5.tgz"
  sha256 "dc2d0ff651c2b275bc4af3af8ba59851a6fb6e1eaddc20ae75fb60b1e90126ec"

  bottle do
    sha256 "04e9492ce0ef247cf6674b6220a5a09cebe84314f6da58d91a3ccdcfb3e9f3e7" => :tiger_altivec
  end

  # Help find ffi.h
  patch :p0, :DATA

  depends_on "libffi"
  depends_on "readline"

  def install
    # Required to use our configuration
    ENV.append_to_cflags "-DNEWCONFIG -c"

    system "./configure-alt", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make"
    system "make check"
    system "make install"
  end

  def caveats; <<-EOS.undent
    If you have brew in a custom prefix, the included examples
    will need to be be pointed to your newlisp executable.
    EOS
  end

  test do
    path = testpath/"test.lsp"
    path.write <<-EOS
      (println "hello")
      (exit 0)
    EOS

    assert_equal "hello\n", shell_output("#{bin}/newlisp #{path}")
  end
end
__END__
--- newlisp.h.orig	2024-03-29 00:00:58.000000000 +0000
+++ newlisp.h	2024-03-29 00:01:22.000000000 +0000
@@ -111,7 +111,7 @@
 #ifdef FFI
 
 #if defined(MAC_OSX)
-#include <ffi/ffi.h>
+#include <ffi.h>
 #endif
 
 #if defined(WINDOWS)  

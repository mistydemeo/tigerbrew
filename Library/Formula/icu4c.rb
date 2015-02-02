class Icu4c < Formula
  homepage "http://site.icu-project.org/"
  head "http://source.icu-project.org/repos/icu/icu/trunk/", :using => :svn
  url "http://download.icu-project.org/files/icu4c/54.1/icu4c-54_1-src.tgz"
  version "54.1"
  sha1 "8c752490bbf31cea26e20246430cee67d48abe34"

  bottle do
    revision 1
    sha1 "244dbb217c95a79f87a35df70aca493a05c9ff39" => :yosemite
    sha1 "a963404c60a1de000c3e9d7478f6318e8f3c9291" => :mavericks
    sha1 "fb48ee8a8fa5aa9537d4e594178bc7e62689156a" => :mountain_lion
  end

  # build tries to pass -compatibility-version to ld, which Tiger's ld can't grok
  depends_on :ld64

  keg_only :provided_by_osx, "OS X provides libicucore.dylib (but nothing else)."

  option :universal
  option :cxx11

  def patches
    # patch submitted upstream: http://bugs.icu-project.org/trac/ticket/9367
    DATA
  end if MacOS.version < :leopard

  def install
    ENV.universal_binary if build.universal?
    # Tiger's libtool chokes if it's passed -w
    ENV.enable_warnings if MacOS.version < :leopard

    ENV.cxx11 if build.cxx11?

    args = ["--prefix=#{prefix}", "--disable-samples", "--disable-tests", "--enable-static"]
    args << "--with-library-bits=64" if MacOS.prefer_64_bit?
    cd "source" do
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
  end
end

__END__
diff --git a/source/common/putil.cpp b/source/common/putil.cpp
index 01b0683..69d89d8 100644
--- a/source/common/putil.cpp
+++ b/source/common/putil.cpp
@@ -124,6 +124,13 @@
 #endif
 
 /*
+ * Mac OS X 10.4 doesn't use its localtime_r() declaration in <time.h> if either _ANSI_SOURCE or _POSIX_C_SOURCE is #defined.
+ */
+#if defined(U_TZNAME) && U_PLATFORM_IS_DARWIN_BASED && (defined(_ANSI_SOURCE) || defined(_POSIX_C_SOURCE))
+U_CFUNC struct tm *localtime_r(const time_t *, struct tm *);
+#endif
+
+/*
  * Only include langinfo.h if we have a way to get the codeset. If we later
  * depend on more feature, we can test on U_HAVE_NL_LANGINFO.
  *


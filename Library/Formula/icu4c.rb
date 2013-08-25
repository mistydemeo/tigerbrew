require 'formula'

class Icu4c < Formula
  homepage 'http://site.icu-project.org/'
  url 'http://download.icu-project.org/files/icu4c/51.1/icu4c-51_1-src.tgz'
  version '51.1'
  sha1 '7905632335e3dcd6667224da0fa087b49f9095e9'
  head 'http://source.icu-project.org/repos/icu/icu/trunk/', :using => :svn

  bottle do
    sha1 '6b5b4ab5704cc2a8b17070a087c7f9594466cf1d' => :mountain_lion
    sha1 'a555b051a65717e1ca731eec5743969d8190a9f8' => :lion
    sha1 'bcb1ab988f67c3d48fb7c5829153c136c16c059b' => :snow_leopard
  end

  # build tries to pass -compatibility-version to ld, which Tiger's ld can't grok
  depends_on :ld64

  keg_only "Conflicts; see: https://github.com/mxcl/homebrew/issues/issue/167"

  option :universal

  def patches
    # patch submitted upstream: http://bugs.icu-project.org/trac/ticket/9367
    DATA
  end if MacOS.version < :leopard

  def install
    ENV.universal_binary if build.universal?
    # Tiger's libtool chokes if it's passed -w
    ENV.enable_warnings if MacOS.version < :leopard

    args = ["--prefix=#{prefix}", "--disable-samples", "--disable-tests", "--enable-static"]
    args << "--with-library-bits=64" if MacOS.prefer_64_bit?
    cd "source" do
      system "./configure", *args
      system "make"
      system "make install"
    end
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


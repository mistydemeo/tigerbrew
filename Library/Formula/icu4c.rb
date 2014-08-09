require "formula"

class Icu4c < Formula
  homepage "http://site.icu-project.org/"
  head "http://source.icu-project.org/repos/icu/icu/trunk/", :using => :svn
  url "http://download.icu-project.org/files/icu4c/53.1/icu4c-53_1-src.tgz"
  version "53.1"
  sha1 "7eca017fdd101e676d425caaf28ef862d3655e0f"

  bottle do
    sha1 "1199e740fbc35f09eaa3774ada8c805c885ca170" => :mavericks
    sha1 "72a163ec611ab7ee984d823fca4202d254627372" => :mountain_lion
    sha1 "69037c3eacbf544ab6191e4290c1bc4a6dbdcda0" => :lion
  end

  # build tries to pass -compatibility-version to ld, which Tiger's ld can't grok
  depends_on :ld64

  keg_only "Conflicts; see: https://github.com/Homebrew/homebrew/issues/issue/167"

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


class Zlib < Formula
  desc "General-purpose lossless data-compression library"
  homepage "http://www.zlib.net/"
  url "https://zlib.net/fossils/zlib-1.3.2.tar.gz"
  sha256 "bb329a0a2cd0274d05519d61c667c062e06990d72e125ee2dfa8de64f0119d16"

  bottle do
    cellar :any
  end

  keg_only :provided_by_osx

  # vsnprintf(3) is available, make sure it is used even when compiler defaults
  # to C89 support. __STDC_VERSION__ definition first appeared in OS X 10.8 Mountain Lion.
  # https://github.com/madler/zlib/pull/1167
  patch :p1, :DATA

  option :universal
  option "with-tests", "Build and run the test suite"

  # http://zlib.net/zlib_how.html
  resource "test_artifact" do
    url "http://zlib.net/zpipe.c"
    version "20260211"
    sha256 "e79717cefd20043fb78d730fd3b9d9cdf8f4642307fc001879dc82ddb468509f"
  end

  def install
    ENV.universal_binary if build.universal?
    # The test in configure to see if shared library support is available
    # is done so by invoking gcc -w and then falls back to building just a
    # static library.
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    system "./configure", "--prefix=#{prefix}"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  test do
    testpath.install resource("test_artifact")
    system ENV.cc, "zpipe.c", "-I#{include}", "-L#{lib}", "-lz", "-o", "zpipe"

    touch "foo.txt"
    output = "./zpipe < foo.txt > foo.txt.z"
    system output
    assert File.exist?("foo.txt.z")
  end
end
__END__
--- a/configure
+++ b/configure
@@ -762,6 +762,8 @@ EOF
 
     if try $CC -c $CFLAGS $test.c; then
       echo "Checking for return value of vsnprintf()... Yes." | tee -a configure.log
+      CFLAGS="$CFLAGS -DHAS_vsnprintf"
+      SFLAGS="$SFLAGS -DHAS_vsnprintf"
     else
       CFLAGS="$CFLAGS -DHAS_vsnprintf_void"
       SFLAGS="$SFLAGS -DHAS_vsnprintf_void"
--- a/gzguts.h
+++ b/gzguts.h
@@ -92,8 +92,8 @@
 #        define vsnprintf _vsnprintf
 #      endif
 #    endif
-#  elif !defined(__STDC_VERSION__) || __STDC_VERSION__-0 < 199901L
-/* Otherwise if C89/90, assume no C99 snprintf() or vsnprintf() */
+#  elif (!defined(__STDC_VERSION__) || __STDC_VERSION__-0 < 199901L) && !defined(HAS_vsnprintf)
+/* Otherwise if C89/90, assume no C99 snprintf() or vsnprintf() unless configure detected it */
 #    ifndef NO_snprintf
 #      define NO_snprintf
 #    endif

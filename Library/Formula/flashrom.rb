class Flashrom < Formula
  desc "Identify, read, write, verify, and erase flash chips"
  homepage "http://flashrom.org/"
  url "https://download.flashrom.org/releases/flashrom-v1.3.0.tar.bz2"
  sha256 "a053234453ccd012e79f3443bdcc61625cf97b7fd7cb4cdd8bfbffbe8b149623"

  head "svn://flashrom.org/flashrom/trunk"

  bottle do
    cellar :any
  end

  # Need strndup(3) via helper
  patch :p0, :DATA

  # Need a compiler with C11 support
  fails_with :gcc
  fails_with :gcc_4_0

  depends_on "pkg-config" => :build
  depends_on "libusb"
  depends_on "libftdi"
  depends_on "make"

  def install
    ENV["CONFIG_RAYER_SPI"] = "0"
    ENV["CONFIG_ENABLE_LIBPCI_PROGRAMMERS"] = "no"

    system "gmake", "DESTDIR=#{prefix}", "PREFIX=/", "install"
    mv sbin, bin
  end

  test do
    system "#{bin}/flashrom" " --version"
  end
end
__END__
--- helpers.c.orig	2024-01-31 21:14:43.000000000 +0000
+++ helpers.c	2024-01-31 21:18:42.000000000 +0000
@@ -102,8 +102,10 @@
 	*nextp = str;
 	return ret;
 }
+#endif
 
-/* strndup is a POSIX function not present in MinGW */
+/* strndup is a POSIX function not present in MinGW nor OS X before 10.7 */
+#if (defined(__MINGW32__) || (defined(__MACH__) && defined(__APPLE__) && defined(__APPLE_CC__) && __APPLE_CC__ < 5658))
 char *strndup(const char *src, size_t maxlen)
 {
 	char *retbuf;
--- include/flash.h.orig	2024-01-31 21:26:35.000000000 +0000
+++ include/flash.h	2024-01-31 21:26:57.000000000 +0000
@@ -462,7 +462,7 @@
 void tolower_string(char *str);
 uint8_t reverse_byte(uint8_t x);
 void reverse_bytes(uint8_t *dst, const uint8_t *src, size_t length);
-#ifdef __MINGW32__
+#if (defined(__MINGW32__) || (defined(__MACH__) && defined(__APPLE__) && defined(__APPLE_CC__) && __APPLE_CC__ < 5658))
 char* strtok_r(char *str, const char *delim, char **nextp);
 char *strndup(const char *str, size_t size);
 #endif

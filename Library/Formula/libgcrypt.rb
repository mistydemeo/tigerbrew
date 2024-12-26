class Libgcrypt < Formula
  desc "Cryptographic library based on the code from GnuPG"
  homepage "https://gnupg.org/software/libgcrypt/"
  url "https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.11.0.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.11.0.tar.bz2"
  sha256 "09120c9867ce7f2081d6aaa1775386b98c2f2f246135761aae47d81f58685b9c"

  bottle do
  end

  # Availability.h appeared in Leopard
  patch :p0, :DATA

  option :universal

  depends_on "libgpg-error"

  resource "config.h.ed" do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/ec8d133/libgcrypt/config.h.ed"
    version "113198"
    sha256 "d02340651b18090f3df9eed47a4d84bed703103131378e1e493c26d7d0c7aab1"
  end

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-asm",
                          "--with-libgpg-error-prefix=#{Formula["libgpg-error"].opt_prefix}"

    if build.universal?
      buildpath.install resource("config.h.ed")
      system "ed -s - config.h <config.h.ed"
    end

    # Parallel builds work, but only when run as separate steps
    system "make"
    system "make", "install"
    system "make", "check"

    # avoid triggering mandatory rebuilds of software that hard-codes this path
    inreplace bin/"libgcrypt-config", prefix, opt_prefix
  end

  test do
    touch "testing"
    output = shell_output("#{bin}/hmac256 \"testing\" testing")
    assert_match "0e824ce7c056c82ba63cc40cffa60d3195b5bb5feccc999a47724cc19211aef6", output
  end
end
__END__
--- random/rndoldlinux.c.orig	2023-11-28 18:04:36.000000000 +0000
+++ random/rndoldlinux.c	2023-11-28 18:05:45.000000000 +0000
@@ -29,7 +29,11 @@
 #include <fcntl.h>
 #include <poll.h>
 #if defined(__APPLE__) && defined(__MACH__)
+#ifdef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
+#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050
 #include <Availability.h>
+#endif
+#endif
 #ifdef __MAC_10_11
 #include <TargetConditionals.h>
 #if !defined(TARGET_OS_IPHONE) || TARGET_OS_IPHONE == 0

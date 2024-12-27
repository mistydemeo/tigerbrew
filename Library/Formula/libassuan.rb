class Libassuan < Formula
  desc "Assuan IPC Library"
  homepage "https://www.gnupg.org/related_software/libassuan/index.en.html"
  url "https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-3.0.1.tar.bz2"
  mirror "ftp://ftp.gnupg.org/gcrypt/libassuan/libassuan-3.0.1.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libassuan/libassuan-3.0.1.tar.bz2"
  sha256 "c8f0f42e6103dea4b1a6a483cb556654e97302c7465308f58363778f95f194b1"

  bottle do
    sha256 "6525f567c7a900362a4de6a85b1d7dea6c6c58ac77a956b2059b28eb795ebadc" => :tiger_altivec
  end

  # Needed for FD_SET(2)
  patch :p0, :DATA

  depends_on "libgpg-error"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--enable-static"
    system "make", "install"
  end

  test do
    system "#{bin}/libassuan-config", "--version"
  end
end
__END__
--- src/assuan-socket.c.orig	2024-12-25 18:24:06.000000000 +0000
+++ src/assuan-socket.c	2024-12-25 18:23:24.000000000 +0000
@@ -35,6 +35,7 @@
 # include <sys/socket.h>
 # include <netinet/in.h>
 # include <arpa/inet.h>
+# include <sys/select.h>
 #endif
 #include <errno.h>
 #ifdef HAVE_SYS_STAT_H

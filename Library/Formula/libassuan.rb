class Libassuan < Formula
  desc "Assuan IPC Library"
  homepage "https://www.gnupg.org/related_software/libassuan/index.en.html"
  url "https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-3.0.2.tar.bz2"
  mirror "ftp://ftp.gnupg.org/gcrypt/libassuan/libassuan-3.0.2.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libassuan/libassuan-3.0.2.tar.bz2"
  sha256 "d2931cdad266e633510f9970e1a2f346055e351bb19f9b78912475b8074c36f6"

  bottle do
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

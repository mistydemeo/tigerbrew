class Netcat < Formula
  desc "Utility for managing network connections"
  homepage "http://netcat.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/netcat/netcat/0.7.1/netcat-0.7.1.tar.bz2"
  sha256 "b55af0bbdf5acc02d1eb6ab18da2acd77a400bafd074489003f3df09676332bb"

  bottle do
    cellar :any
  end

  # Need the type definition for bool
  patch :p0, :DATA

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--infodir=#{info}"
    system "make", "install"
  end

  test do
    assert_match "HTTP/1.0", pipe_output("#{bin}/nc www.google.com 80", "GET / HTTP/1.0\r\n\r\n")
  end
end
__END__
--- src/netcat.h.orig	2025-10-09 22:39:58.000000000 +0100
+++ src/netcat.h	2025-10-09 22:40:25.000000000 +0100
@@ -38,6 +38,7 @@
 #include <sys/socket.h>
 #include <sys/uio.h>		/* needed for reading/writing vectors */
 #include <sys/param.h>		/* defines MAXHOSTNAMELEN and other stuff */
+#include <stdbool.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>		/* inet_ntop(), inet_pton() */
 

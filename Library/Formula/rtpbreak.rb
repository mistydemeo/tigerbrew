class Rtpbreak < Formula
  # Homepage and URL dead since at least Feb 2015
  desc "Detect, reconstruct and analyze any RTP session"
  homepage "http://www.dallachiesa.com/code/rtpbreak/doc/rtpbreak_en.html"
  url "http://dallachiesa.com/code/rtpbreak/rtpbreak-1.3a.tgz"
  mirror "https://dl.bintray.com/homebrew/mirror/rtpbreak-1.3a.tgz"
  sha256 "9ec7276e3775c13306bcf90ba573cfb77b8162a18f90d5805a3c5a288f4466f8"


  depends_on "libnet"

  # main.c is missing the netinet/udp.h header; reported upstream by email
  patch :p0, :DATA

  def install
    bin.mkpath
    system "make", "CC=#{ENV.cc}"
    system "make", "install", "INSTALL_DIR=#{bin}"
  end

  test do
    assert_match /payload/, shell_output("#{bin}/rtpbreak -k")
  end
end

__END__

--- src/main.c  2012-06-30 12:22:29.000000000 +0200
+++ src/main.c  2012-06-30 12:19:11.000000000 +0200
@@ -25,6 +25,7 @@
 
 #include <time.h>
 #include <sys/stat.h>
+#include <netinet/udp.h>
 #include <pwd.h>
 #include <grp.h>
 #include "queue.h"

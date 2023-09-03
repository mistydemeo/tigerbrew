class Libpcap < Formula
  desc "Portable library for network traffic capture"
  homepage "http://www.tcpdump.org/"
  url "https://www.tcpdump.org/release/libpcap-1.10.4.tar.gz"
  sha256 "ed19a0383fad72e3ad435fd239d7cd80d64916b87269550159d20e47160ebe5f"
  head "git://bpf.tcpdump.org/libpcap"

  bottle do
    sha256 "0000924199fe3a29f3e53efd108d8745707302d613faf97f938ff730b6264d0a" => :tiger_altivec
  end

  # Availability.h was introduced in 10.5, guard it off
  # https://github.com/the-tcpdump-group/libpcap/pull/1203
  patch :p0, :DATA

  keg_only :provided_by_osx

  # System versions are too old on older OS Xs
  # https://github.com/mistydemeo/tigerbrew/issues/574
  depends_on "bison" => :build
  depends_on "flex" => :build

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--enable-ipv6",
                          "--disable-universal"
    system "make", "install"
  end

  test do
    assert_match /lpcap/, shell_output("#{bin}/pcap-config --libs")
  end
end
__END__
--- pcap/funcattrs.h.orig	2023-07-06 02:23:58.000000000 +0100
+++ pcap/funcattrs.h	2023-07-06 02:25:05.000000000 +0100
@@ -181,7 +181,11 @@
  * I've never seen earlier releases.
  */
 #ifdef __APPLE__
-#include <Availability.h>
+#ifndef __MAC_OS_X_VERSION_MIN_REQUIRED
+#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050
+ # include <Availability.h>
+#endif
+#endif
 /*
  * When building as part of macOS, define this as __API_AVAILABLE(__VA_ARGS__).
  *

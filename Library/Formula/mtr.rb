class Mtr < Formula
  desc "'traceroute' and 'ping' in a single tool"
  homepage "http://www.bitwizard.nl/mtr/"
  url "https://github.com/traviscross/mtr/archive/refs/tags/v0.96.tar.gz"
  sha256 "73e6aef3fb6c8b482acb5b5e2b8fa7794045c4f2420276f035ce76c5beae632d"
  # Main license is GPL-2.0-only but some compatibility code is under other licenses:
  # 1. portability/queue.h is BSD-3-Clause
  # 2. portability/error.* is LGPL-2.0-only (only used on macOS)
  # 3. portability/getopt.* is omitted as unused
  license all_of: ["GPL-2.0-only", "BSD-3-Clause", "LGPL-2.0-only"]

  bottle do
    cellar :any_skip_relocation
  end

  head do
    url "https://github.com/traviscross/mtr.git"
  end

  # Fix build on Tiger & Leopard
  # https://github.com/traviscross/mtr/pull/540
  patch :DATA

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gtk+" => :optional
  depends_on "jansson"
  depends_on "ncurses" # Needed for braille output.

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]
    args << "--without-gtk" if build.without? "gtk+"
    system "./bootstrap.sh"
    system "./configure", *args
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    mtr requires root privileges so you will need to run `sudo mtr`.
    You should be certain that you trust any software you grant root privileges.

    Braille output requires your shell's locale to be set to UTF-8.
    By default locale is set to C in Terminal on Tiger because $LANG is not set in.
    Check the output of the 'locale' command and 'export LANG=en_GB.UTF-8' before
    running mtr, if $LANG is set to C. See the output of 'locale -a' for a list
    of supported locales, and substitue en_GB with your desired locale.
    EOS
  end
end
__END__
diff --git a/packet/construct_unix.c b/packet/construct_unix.c
index 95fefba..51894a1 100644
--- a/packet/construct_unix.c
+++ b/packet/construct_unix.c
@@ -250,7 +250,6 @@ int construct_udp6_packet(
     int packet_size,
     const struct probe_param_t *param)
 {
-    int udp_socket = net_state->platform.udp6_send_socket;
     struct UDPHeader *udp;
     int udp_size;
 
@@ -428,19 +427,28 @@ int set_stream_socket_options(
     }
 
     /*  Set the "type of service" field of the IP header  */
+#ifdef IPV6_TCLASS
     if (param->ip_version == 6) {
         level = IPPROTO_IPV6;
         opt = IPV6_TCLASS;
     } else {
+#else
+    opt = 0;
+    if (param->ip_version == 4) {
+#endif
         level = IPPROTO_IP;
         opt = IP_TOS;
     }
 
-    if (setsockopt(stream_socket, level, opt,
-                   &param->type_of_service, sizeof(int)) == -1) {
+    /* Avoid trying to set on IPv6 stacks which lack RFC 3542 support (IPV6_TCLASS) */
+    if (opt != 0) {
+        if (setsockopt(stream_socket, level, opt,
+                       &param->type_of_service, sizeof(int)) == -1) {
 
-        return -1;
+            return -1;
+        }
     }
+
 #ifdef SO_MARK
     if (param->routing_mark) {
         if (set_socket_mark(stream_socket, param->routing_mark)) {
@@ -836,11 +844,13 @@ int construct_ip6_packet(
         }
     }
 
+#ifdef IPV6_TCLASS
     /*  The traffic class in IPv6 is analogous to ToS in IPv4  */
     if (setsockopt(send_socket, IPPROTO_IPV6,
                    IPV6_TCLASS, &param->type_of_service, sizeof(int))) {
         return -1;
     }
+#endif
 
     /*  Set the time-to-live  */
     if (setsockopt(send_socket, IPPROTO_IPV6,
diff --git a/ui/asn.c b/ui/asn.c
index 111c394..28f5cd3 100644
--- a/ui/asn.c
+++ b/ui/asn.c
@@ -30,9 +30,6 @@
 #endif
 #include <errno.h>
 
-#ifdef __APPLE__
-#define BIND_8_COMPAT
-#endif
 #include <arpa/nameser.h>
 #ifdef HAVE_ARPA_NAMESER_COMPAT_H
 #include <arpa/nameser_compat.h>

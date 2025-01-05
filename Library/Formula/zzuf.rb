class Zzuf < Formula
  desc "Transparent application input fuzzer"
  homepage "http://caca.zoy.org/wiki/zzuf"
  url "https://github.com/samhocevar/zzuf/releases/download/v0.15/zzuf-0.15.tar.gz"
  sha256 "a34f624503e09acd269c70d826aac2a35c03e84dc351873f140f0ba6a792ffd6"
  license "WTFPL"

  bottle do
    sha256 "dc5911937b4a7a248bed06334cda43b87de29990f4c67ab80e2b703bef20cf3c" => :tiger_altivec
  end

  # MAP_ANON is guarded off on Tiger with #ifndef _POSIX_C_SOURCE
  patch :p0, :DATA

  # ld: Undefined symbols:
  # ___sync_lock_test_and_set
  # ___sync_synchronize
  fails_with :gcc_4_0

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    output = pipe_output("#{bin}/zzuf -i -B 4194304 -r 0.271828 -s 314159 -m < /dev/zero").chomp
    assert_equal "zzuf[s=314159,r=0.271828]: 549e1200590e9c013e907039fe535f41", output
  end
end
__END__
--- src/libzzuf/lib-mem.c.orig	2024-06-20 23:40:20.000000000 +0100
+++ src/libzzuf/lib-mem.c	2024-06-20 23:41:03.000000000 +0100
@@ -29,8 +29,10 @@
 /* Use this to get ENOMEM on HP-UX */
 #define _INCLUDE_POSIX_SOURCE
 /* Need this to get standard mmap() on OpenSolaris */
+#if defined(__sun)
 #undef _POSIX_C_SOURCE
 #define _POSIX_C_SOURCE 3
+#endif
 /* Need this to get valloc() on OpenSolaris */
 #define __EXTENSIONS__
 /* Need this to include <libc.h> on OS X */

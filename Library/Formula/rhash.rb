class Rhash < Formula
  desc "Utility for computing and verifying hash sums of files"
  homepage "https://rhash.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/rhash/rhash/1.4.5/rhash-1.4.5-src.tar.gz"
  mirror "https://github.com/rhash/RHash/archive/refs/tags/v1.4.5.tar.gz"
  sha256 "6db837e7bbaa7c72c5fd43ca5af04b1d370c5ce32367b9f6a1f7b49b2338c09a"
  license "0BSD"
  revision 1

  head "https://github.com/rhash/RHash.git"

  bottle do
    sha256 "7881119273fd9797cc8425cab6236a9d924bd6aa33653b9ded1275f93dfab5b5" => :tiger_altivec
  end

  # wants to pass -install_name to the linker
  depends_on :ld64
  depends_on "openssl3"

  # __has_builtin landed in GCC 10
  # https://github.com/rhash/RHash/issues/269
  patch :p0, :DATA

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-gettext
      --extra-cflags=-std=gnu99
      --extra-cflags=-I#{Formula["openssl3"].opt_include}
      --extra-ldflags=-L#{Formula["openssl3"].opt_lib}
    ]
    # posix_memalign(3) showed up in Snow Leopard
    args << "--extra-cflags=-DNO_POSIX_ALIGNED_ALLOC" if MacOS.version < :snow_leopard

    system "./configure", *args
    system "make"
    system "make", "install", "install-pkg-config"
    system "make", "-C", "librhash", "install-lib-headers"
    lib.install_symlink (lib/"librhash.#{version.major.to_s}.dylib") => "librhash.dylib"
  end

  test do
    (testpath/"test").write("test")
    (testpath/"test.sha1").write("a94a8fe5ccb19ba61c4c0873d391e987982fbbd3 test")
    system "#{bin}/rhash", "-c", "test.sha1"
  end
end

__END__
--- common_func.h.orig	2024-11-15 23:59:13.000000000 +0000
+++ common_func.h	2024-11-15 23:59:25.000000000 +0000
@@ -142,6 +142,10 @@
 #define rsh_tstrdup(str) rsh_strdup(str)
 #endif
 
+#ifndef __has_builtin
+# define __has_builtin(x) 0
+#endif
+
 /* get_ctz - count traling zero bits */
 #if (defined(__GNUC__) && (__GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4))) || \
     (defined(__clang__) && __has_builtin(__builtin_ctz))

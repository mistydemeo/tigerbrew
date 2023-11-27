class Libxcrypt < Formula
  desc "Extended crypt library for descrypt, md5crypt, bcrypt, and others"
  homepage "https://github.com/besser82/libxcrypt"
  url "https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz"
  sha256 "e5e1f4caee0a01de2aee26e3138807d6d3ca2b8e67287966d1fefd65e1fd8943"
  license "LGPL-2.1-or-later"

  bottle do
    cellar :any
    sha256 "c6b64d4c959babe638d70396564564bec0892ee5f703e24d1b64650bb7d7eb66" => :tiger_altivec
  end

  # Skip the compile-strong-alias test since it's just a sanity check for future versions
  # and imposes a new compiler requirement whereas everything builds and tests ok otherwise
  # with GCC 4.0.
  patch :p0, :DATA

  keg_only :provided_by_osx

  # Perl version 5.14.0 or later is required
  depends_on "perl" => :build
  depends_on "make" => :build

  link_overwrite "include/crypt.h"
  link_overwrite "lib/libcrypt.so"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-obsolete-api",
                          "--disable-xcrypt-compat-files",
                          "--disable-failure-tokens",
                          "--disable-valgrind",
                          "MAKE=gmake"
    system "gmake", "check"
    system "gmake", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <crypt.h>
      #include <errno.h>
      #include <stdio.h>
      #include <string.h>

      int main()
      {
        char *hash = crypt("abc", "$2b$05$abcdefghijklmnopqrstuu");

        if (errno) {
          fprintf(stderr, "Received error: %s", strerror(errno));
          return errno;
        }
        if (hash == NULL) {
          fprintf(stderr, "Hash is NULL");
          return -1;
        }
        if (strcmp(hash, "$2b$05$abcdefghijklmnopqrstuuRWUgMyyCUnsDr8evYotXg5ZXVF/HhzS")) {
          fprintf(stderr, "Unexpected hash output");
          return -1;
        }

        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lcrypt", "-o", "test"
    system "./test"
  end
end
__END__
--- Makefile.in.orig	2023-11-16 02:28:32.000000000 +0000
+++ Makefile.in	2023-11-16 02:28:46.000000000 +0000
@@ -169,7 +169,7 @@
 	test/alg-sha512$(EXEEXT) test/alg-yescrypt$(EXEEXT) \
 	test/badsalt$(EXEEXT) test/badsetting$(EXEEXT) \
 	test/byteorder$(EXEEXT) test/checksalt$(EXEEXT) \
-	test/compile-strong-alias$(EXEEXT) test/crypt-badargs$(EXEEXT) \
+	test/crypt-badargs$(EXEEXT) \
 	test/crypt-gost-yescrypt$(EXEEXT) test/explicit-bzero$(EXEEXT) \
 	test/gensalt$(EXEEXT) test/gensalt-extradata$(EXEEXT) \
 	test/gensalt-nthash$(EXEEXT) test/getrandom-fallbacks$(EXEEXT) \

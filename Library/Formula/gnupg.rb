require 'formula'

class Gnupg < Formula
  homepage 'http://www.gnupg.org/'
  url 'ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.15.tar.bz2'
  sha1 '63ebf0ab375150903c65738070e4105200197fd4'

  option '8192', 'Build with support for private keys of up to 8192 bits'

  # fixes IDEA tests on PPC; should be fixed in next release
  def patches; DATA; end

  def cflags
    cflags = ENV.cflags.to_s
    cflags += ' -std=gnu89 -fheinous-gnu-extensions' if ENV.compiler == :clang
    cflags
  end

  def install
    inreplace 'g10/keygen.c', 'max=4096', 'max=8192' if build.include? '8192'

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-asm"
    system "make", "CFLAGS=#{cflags}"
    system "make check"

    # we need to create these directories because the install target has the
    # dependency order wrong
    [bin, libexec/'gnupg'].each(&:mkpath)
    system "make install"
  end
end

__END__
diff -up gnupg-1.4.13/cipher/idea.c.endian gnupg-1.4.13/cipher/idea.c
--- gnupg-1.4.13/cipher/idea.c.endian	2013-01-07 08:37:48.899033247 -0500
+++ gnupg-1.4.13/cipher/idea.c	2013-01-07 08:39:03.239030102 -0500
@@ -201,7 +201,7 @@ cipher( byte *outbuf, const byte *inbuf,
     x2 = *in++;
     x3 = *in++;
     x4 = *in;
-  #ifndef WORDS_BIGENDIAN
+  #ifndef BIG_ENDIAN_HOST
     x1 = (x1>>8) | (x1<<8);
     x2 = (x2>>8) | (x2<<8);
     x3 = (x3>>8) | (x3<<8);
@@ -234,7 +234,7 @@ cipher( byte *outbuf, const byte *inbuf,
     MUL(x4, *key);
 
     out = (u16*)outbuf;
-  #ifndef WORDS_BIGENDIAN
+  #ifndef BIG_ENDIAN_HOST
     *out++ = (x1>>8) | (x1<<8);
     *out++ = (x3>>8) | (x3<<8);
     *out++ = (x2>>8) | (x2<<8);


# GnuTLS has previous, current, and next stable branches, we use current.
class Gnutls < Formula
  desc "GNU Transport Layer Security (TLS) Library"
  homepage "https://gnutls.org"
  url "https://www.gnupg.org/ftp/gcrypt/gnutls/v3.7/gnutls-3.7.10.tar.xz"
  mirror "http://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnutls/v3.7/gnutls-3.7.10.tar.xz"
  sha256 "b6e4e8bac3a950a3a1b7bdb0904979d4ab420a81e74de8636dd50b467d36f5a9"
  revision 1

  bottle do
    sha256 "e73772d9c5c7f5d7b03bb30e0e82778d8f90b6b687d1f1d7c51561ef3f001cf4" => :tiger_altivec
  end

  # Need a C11/C++11 compiler
  fails_with :gcc_4_0
  fails_with :gcc

  # Availability.h appeared in Leopard
  patch :p0, :DATA

  depends_on "pkg-config" => :build
  depends_on "curl-ca-bundle"
  depends_on "libtasn1"
  depends_on "gmp"
  depends_on "nettle"
  depends_on "libunistring"
  depends_on "libidn2"
  depends_on "p11-kit"
  depends_on "zlib"
  depends_on "guile" => :optional
  depends_on "unbound" => :optional

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-static
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-default-trust-store-file=#{gnutlsdir}
      --disable-heartbeat-support
    ]

    if build.with? "guile"
      args << "--enable-guile"
      args << "--with-guile-site-dir=no"
    end

    system "./configure", *args
    system "make", "install"

    # certtool shadows the OS X certtool utility
    mv bin/"certtool", bin/"gnutls-certtool"
    mv man1/"certtool.1", man1/"gnutls-certtool.1"
  end

  def gnutlsdir
    etc/"gnutls"
  end

  def post_install
    rm_f gnutlsdir/"cert.pem"
    gnutlsdir.install_symlink Formula["curl-ca-bundle"].opt_share/"ca-bundle.crt" => "cert.pem"
  end

  test do
    system bin/"gnutls-cli", "--version"
  end
end
__END__
--- lib/system/certs.c.orig	2023-11-28 15:21:28.000000000 +0000
+++ lib/system/certs.c	2023-11-28 15:20:40.000000000 +0000
@@ -47,8 +47,12 @@
 #ifdef __APPLE__
 # include <CoreFoundation/CoreFoundation.h>
 # include <Security/Security.h>
+#ifdef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
+#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050
 # include <Availability.h>
 #endif
+#endif
+#endif
 
 /* System specific function wrappers for certificate stores.
  */

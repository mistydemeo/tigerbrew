# GnuTLS has previous, current, and next stable branches, we use current.
# From 3.4.0 GnuTLS will be permanently disabling SSLv3. Every brew uses will need a revision with that.
# http://nmav.gnutls.org/2014/10/what-about-poodle.html
class Gnutls < Formula
  desc "GNU Transport Layer Security (TLS) Library"
  homepage "http://gnutls.org"
  url "ftp://ftp.gnutls.org/gcrypt/gnutls/v3.3/gnutls-3.3.18.tar.xz"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnutls/v3.3/gnutls-3.3.18.tar.xz"
  sha256 "7a87e7f486d1ada10007356917a412cde6c6114dac018e3569e3aa09e9f29395"

  bottle do
    cellar :any
    sha256 "72af0d7211a6e17f9bea7969b8ff17b1a36377958cbc349f1b7a115b291ee172" => :leopard_g3
    sha256 "8f88d5527c44d52000b3c0243f2740edc27c5fba80ffb5764e0aef2757055c08" => :leopard_altivec
  end

  depends_on "pkg-config" => :build
  depends_on "libtasn1"
  depends_on "gmp"
  depends_on "nettle"
  depends_on "guile" => :optional
  depends_on "p11-kit" => :optional
  depends_on "unbound" => :optional

  fails_with :llvm do
    build 2326
    cause "Undefined symbols when linking"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-static
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-default-trust-store-file=#{etc}/openssl/cert.pem
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

  def post_install
    keychains = %w[
      /Library/Keychains/System.keychain
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    certs_list = `security find-certificate -a -p #{keychains.join(" ")}`
    certs = certs_list.scan(
      /-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m
    )

    valid_certs = certs.select do |cert|
      IO.popen("openssl x509 -inform pem -checkend 0 -noout", "w") do |openssl_io|
        openssl_io.write(cert)
      end

      $?.success?
    end

    openssldir = etc/"openssl"
    openssldir.mkpath
    (openssldir/"cert.pem").atomic_write(valid_certs.join("\n"))
  end

  test do
    system bin/"gnutls-cli", "--version"
  end
end

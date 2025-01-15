class Libressl < Formula
  desc "Version of the SSL/TLS protocol forked from OpenSSL"
  homepage "http://www.libressl.org/"
  url "https://cdn.openbsd.org/pub/OpenBSD/LibreSSL/libressl-4.0.0.tar.gz"
  sha256 "4d841955f0acc3dfc71d0e3dd35f283af461222350e26843fea9731c0246a1e4"

  head do
    url "https://github.com/libressl-portable/portable.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  bottle do
    sha256 "799aa0abc751239e60eadeaca256d8fa3d208a992090572ec4c5c06d1d59de50" => :tiger_altivec
  end

  keg_only "LibreSSL is not linked to prevent conflict with the system OpenSSL."

  option "with-tests", "Build and run the test suite"

  depends_on "curl-ca-bundle"

  def install
    # Tests fail during "make check" stage when built with CPU optimisation
    ENV.no_optimization
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-openssldir=#{libressldir}
      --sysconfdir=#{libressldir}
    ]

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  def libressldir
    etc/"libressl"
  end

  def post_install
    # LibreSSL installs a default cert.pem - Use curl-ca-bundle's for consistency.
    rm_f libressldir/"cert.pem"
    libressldir.install_symlink Formula["curl-ca-bundle"].opt_share/"ca-bundle.crt" => "cert.pem"
  end

  def caveats; <<-EOS.undent
    A CA file has been bootstrapped using certificates from the system
    keychain. To add additional certificates, place .pem files in
      #{etc}/libressl/certs

    and run
      #{opt_bin}/openssl certhash #{etc}/libressl/certs
    EOS
  end

  test do
    # Make sure the necessary .cnf file exists, otherwise LibreSSL gets moody.
    cnf_path = HOMEBREW_PREFIX/"etc/libressl/openssl.cnf"
    assert cnf_path.exist?,
            "LibreSSL requires the .cnf file for some functionality"

    # Check LibreSSL itself functions as expected.
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system "#{bin}/openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end

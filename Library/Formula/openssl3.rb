class Openssl3 < Formula
  desc "Cryptography and SSL/TLS Toolkit"
  homepage "https://openssl.org/"
  url "https://www.openssl.org/source/openssl-3.3.1.tar.gz"
  mirror "https://github.com/openssl/openssl/releases/download/openssl-3.3.1/openssl-3.3.1.tar.gz"
  sha256 "777cd596284c883375a2a7a11bf5d2786fc5413255efab20c50d6ffe6d020b7e"
  license "Apache-2.0"

  bottle do
  end

  keg_only :provided_by_osx

  depends_on "curl-ca-bundle"
  depends_on "perl"

  # SSLv2 died with 1.1.0, so no-ssl2 no longer required.
  # SSLv3 & zlib are off by default with 1.1.0 but this may not
  # be obvious to everyone, so explicitly state it for now to
  # help debug inevitable breakage.
  def configure_args
    args = %W[
      --prefix=#{prefix}
      --openssldir=#{openssldir}
      --libdir=#{lib}
      no-ssl3
      no-ssl3-method
      no-zlib
    ]
    # No {get,make,set}context support before Leopard
    args << "no-async" if MacOS.version == :tiger
    if Hardware::CPU.ppc?
      args << "darwin-ppc-cc"
    elsif Hardware::CPU.intel?
      args << (Hardware::CPU.is_64_bit? && MacOS.version > :leopard ? "darwin64-x86_64-cc" : "darwin-i386-cc")
    end
    args
  end

  def install
    # The build itself tries to set optimisation flags between none & -O3 by default.
    ENV.no_optimization
    # Build breaks passing -w
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    # Leopard and newer have the crypto framework
    ENV.append_to_cflags "-DOPENSSL_NO_APPLE_CRYPTO_RANDOM" if MacOS.version == :tiger

    # Use timegm()
    # crypto/asn1/a_time.c: In function 'ossl_asn1_string_to_time_t':
    # crypto/asn1/a_time.c:659: error: invalid operands to binary -
    # https://github.com/openssl/openssl/commit/0176fc78d090210cd7e231a7c2c4564464509506
    ENV.append_to_cflags "-DUSE_TIMEGM" if MacOS.version == :tiger

    # This ensures where Homebrew's Perl is needed the Cellar path isn't
    # hardcoded into OpenSSL's scripts, causing them to break every Perl update.
    # Whilst our env points to opt_bin, by default OpenSSL resolves the symlink.
    ENV["PERL"] = Formula["perl"].opt_bin/"perl" if which("perl") == Formula["perl"].opt_bin/"perl"

    openssldir.mkpath
    system "perl", "./Configure", *(configure_args)
    system "make"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
    system "make", "test"
  end

  def openssldir
    etc/"openssl@3"
  end

  def post_install
    rm_f openssldir/"cert.pem"
    openssldir.install_symlink Formula["curl-ca-bundle"].opt_share/"ca-bundle.crt" => "cert.pem"
  end

  def caveats
    <<~EOS
      A CA file has been bootstrapped using certificates from the system
      keychain. To add additional certificates, place .pem files in
        #{openssldir}/certs

      and run
        #{opt_bin}/c_rehash
    EOS
  end

  test do
    # Make sure the necessary .cnf file exists, otherwise OpenSSL gets moody.
    assert_predicate openssldir/"openssl.cnf", :exist?,
            "OpenSSL requires the .cnf file for some functionality"

    # Check OpenSSL itself functions as expected.
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system bin/"openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end

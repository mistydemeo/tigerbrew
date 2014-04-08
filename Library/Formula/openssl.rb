require 'formula'

class Openssl < Formula
  homepage 'http://openssl.org'
  url 'https://www.openssl.org/source/openssl-1.0.1g.tar.gz'
  mirror 'http://mirrors.ibiblio.org/openssl/source/openssl-1.0.1g.tar.gz'
  # This has to be an sha1 because Tiger's system openssl doesn't do sha256;
  # we depend on Homebrew's openssl to calculate sha256 hashes
  sha1 'b28b3bcb1dc3ee7b55024c9f795be60eb3183e3c'

  bottle do
    sha1 "d8c38bb2fe4dfd8930ea02f87d4b958a2a33b051" => :mavericks
    sha1 "536d1e6bd5e1321eb603b4ed1ad131ea86a2794c" => :mountain_lion
    sha1 "f12f352e67e5b131c1935040f8d2ca24107ebfca" => :lion
  end

  depends_on "makedepend" => :build if MacOS.prefer_64_bit?

  keg_only :provided_by_osx,
    "The OpenSSL provided by OS X is too old for some software."

  def install
    args = %W[./Configure
               --prefix=#{prefix}
               --openssldir=#{openssldir}
               zlib-dynamic
               shared
               enable-cms
             ]

    if Hardware::CPU.type == :intel
      if MacOS.prefer_64_bit?
        args << "darwin64-x86_64-cc" << "enable-ec_nistp_64_gcc_128"
      else
        args << "darwin-i386-cc"
      end
    else
      args << (MacOS.prefer_64_bit? ? "darwin64-ppc-cc" : "darwin-ppc-cc")
    end

    # build error from ASM; see https://trac.macports.org/ticket/33741
    args << "no-asm" if MacOS.version == :tiger

    system "perl", *args

    ENV.deparallelize
    system "make", "depend" if MacOS.prefer_64_bit? && Hardware::CPU.type == :intel
    system "make"
    system "make", "test"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end

  def openssldir
    etc/"openssl"
  end

  def cert_pem
    openssldir/"cert.pem"
  end

  def osx_cert_pem
    openssldir/"osx_cert.pem"
  end

  def write_pem_file
    keychains = %w[
      /Library/Keychains/System.keychain
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    osx_cert_pem.atomic_write `security find-certificate -a -p #{keychains.join(" ")}`
  end

  # This method of fetching the system certs doesn't work on Tiger,
  # and is of questionable utility on Leopard too.
  def post_install
    openssldir.mkpath

    if cert_pem.exist?
      write_pem_file
    else
      cert_pem.unlink if cert_pem.symlink?
      write_pem_file
      openssldir.install_symlink 'osx_cert.pem' => 'cert.pem'
    end
  end if MacOS.version > :leopard

  def caveats; <<-EOS.undent
    To install updated CA certs from Mozilla.org:

        brew install curl-ca-bundle
    EOS
  end

  test do
    (testpath/'testfile.txt').write("This is a test file")
    expected_checksum = "91b7b0b1e27bfbf7bc646946f35fa972c47c2d32"
    system "#{bin}/openssl", 'dgst', '-sha1', '-out', 'checksum.txt', 'testfile.txt'
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end

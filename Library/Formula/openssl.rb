require 'formula'

class Openssl < Formula
  homepage 'http://openssl.org'
  url 'http://www.openssl.org/source/openssl-1.0.1e.tar.gz'
  mirror 'http://mirrors.ibiblio.org/openssl/source/openssl-1.0.1e.tar.gz'
  # This has to be an sha1 because Tiger's system openssl doesn't do sha256;
  # we depend on Homebrew's openssl to calculate sha256 hashes
  sha1 '3f1b1223c9e8189bfe4e186d86449775bd903460'

  keg_only :provided_by_osx,
    "The OpenSSL provided by OS X is too old for some software."

  def install
    args = %W[./Configure
               --prefix=#{prefix}
               --openssldir=#{openssldir}
               zlib-dynamic
               shared
             ]

    if Hardware::CPU.type == :intel
      if MacOS.prefer_64_bit?
        args << "darwin64-x86_64-cc" << "enable-ec_nistp_64_gcc_128"

        # -O3 is used under stdenv, which results in test failures when using clang
        inreplace 'Configure',
          %{"darwin64-x86_64-cc","cc:-arch x86_64 -O3},
          %{"darwin64-x86_64-cc","cc:-arch x86_64 -Os}

        setup_makedepend_shim
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

  def setup_makedepend_shim
    path = buildpath/"brew/makedepend"
    path.write <<-EOS.undent
      #!/bin/sh
      exec "#{ENV.cc}" -M "$@"
      EOS
    path.chmod 0755
    ENV.prepend_path 'PATH', path.parent
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
    system "security find-certificate -a -p /Library/Keychains/System.keychain > '#{osx_cert_pem}.tmp'"
    system "security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain >> '#{osx_cert_pem}.tmp'"
    system "mv", "-f", "#{osx_cert_pem}.tmp", osx_cert_pem
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
  end if MacOS.version <= :leopard
end

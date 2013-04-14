require 'formula'

class Openssl < Formula
  homepage 'http://openssl.org'
  url 'http://openssl.org/source/openssl-1.0.1e.tar.gz'
  sha1 '3f1b1223c9e8189bfe4e186d86449775bd903460'

  keg_only :provided_by_osx,
    "The OpenSSL provided by OS X is too old for some software."

  def install
    args = %W[./Configure
               --prefix=#{prefix}
               --openssldir=#{etc}/openssl
               zlib-dynamic
               shared
             ]

    if Hardware.cpu_type == :intel
      if MacOS.prefer_64_bit?
        args << "darwin64-x86_64-cc" << "enable-ec_nistp_64_gcc_128"
      else
        args << "darwin-i386-cc"
      end
    else
      args << (MacOS.prefer_64_bit? ? "darwin-ppc64-cc" : "darwin-ppc-cc")
    end

    # build error from ASM; see https://trac.macports.org/ticket/33741
    args << "no-asm" if MacOS.version == :tiger

    system "perl", *args

    ENV.deparallelize # Parallel compilation fails
    system "make"
    system "make", "test"
    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"
  end

  def caveats; <<-EOS.undent
    To install updated CA certs from Mozilla.org:

        brew install curl-ca-bundle
    EOS
  end
end

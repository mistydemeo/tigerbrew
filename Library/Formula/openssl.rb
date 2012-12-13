require 'formula'

class Openssl < Formula
  homepage 'http://openssl.org'
  url 'http://openssl.org/source/openssl-1.0.1c.tar.gz'
  sha1 '91b684de947cb021ac61b8c51027cc4b63d894ce'

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
      args << (MacOS.prefer_64_bit? ? "darwin64-x86_64-cc" : "darwin-i386-cc")
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
end

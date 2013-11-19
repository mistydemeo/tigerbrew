require 'formula'

class Pcre < Formula
  homepage 'http://www.pcre.org/'
  url 'http://downloads.sourceforge.net/project/pcre/pcre/8.33/pcre-8.33.tar.bz2'
  mirror 'ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.33.tar.bz2'
  sha256 'c603957a4966811c04af5f6048c71cfb4966ec93312d7b3118116ed9f3bc0478'

  option :universal

  # See https://github.com/mistydemeo/tigerbrew/issues/93
  fails_with :gcc do
    build 5553
    cause "One test failure on G4"
  end

  fails_with :llvm do
    build 2326
    cause "Bus error in ld on SL 10.6.4"
  end

  def install
    ENV.universal_binary if build.universal?

    args = [ "--disable-dependency-tracking",
              "--prefix=#{prefix}",
              "--enable-utf8",
              "--enable-unicode-properties",
              "--enable-pcregrep-libz",
              "--enable-pcregrep-libbz2" ]

    # JIT fails tests very badly on PPC right now
    args << "--enable-jit" unless Hardware::CPU.type == :ppc

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make test"
    system "make install"
  end
end

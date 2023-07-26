require 'formula'

class CyrusSasl < Formula
  # This formula uses 2.1.22 because, while later versions build on Tiger,
  # they don't seem to work properly when sending mail
  homepage "http://cyrusimap.org"
  url "https://ftp.osuosl.org/pub/blfs/conglomeration/cyrus-sasl/cyrus-sasl-2.1.22.tar.gz"
  sha256 "c69e3853f35b14ee2c3f6e876e42d880927258ff4678aa052e5f0853db209962"

  keg_only :provided_by_osx

  def install
    system "./configure",
           "--disable-macos-framework",
           "--prefix=#{prefix}"
           # The below are for 2.1.26, which built but wouldn't work
           # with sending and gmail.  The flags were necessary to get
           # a succesful build, IIRC.
           #"--disable-scram",
           #"--disable-gssapi",
    system "make"
    system "make check"
    system "make install"
  end

end


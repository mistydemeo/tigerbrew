require 'formula'

class CyrusSasl < Formula
  # This formula uses 2.1.22 because, while later versions build on Tiger,
  # they don't seem to work properly when sending mail
  homepage 'http://cyrusimap.org'
  url 'ftp://ftp.cyrusimap.org/cyrus-sasl/OLD-VERSIONS/cyrus-sasl-2.1.22.tar.gz'
  sha1 'd23454ab12054714ab97d229c86cb934ce63fbb1'

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


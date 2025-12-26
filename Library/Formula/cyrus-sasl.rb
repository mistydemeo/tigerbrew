require 'formula'

class CyrusSasl < Formula
  homepage "http://cyrusimap.org"
  url "https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.28/cyrus-sasl-2.1.28.tar.gz"
  sha256 "7ccfc6abd01ed67c1a0924b353e526f1b766b21f42d4562ee635a8ebfc5bb38c"

  bottle do
  end

  keg_only :provided_by_osx

  depends_on "openssl3"

  def install
    system "./configure",
           "--disable-macos-framework",
           "--prefix=#{prefix}",
           "--disable-gssapi"
    system "make"
    system "make check"
    system "make install"
  end

end


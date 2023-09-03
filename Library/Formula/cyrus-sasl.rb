require 'formula'

class CyrusSasl < Formula
  homepage "http://cyrusimap.org"
  url "https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.28/cyrus-sasl-2.1.28.tar.gz"
  sha256 "7ccfc6abd01ed67c1a0924b353e526f1b766b21f42d4562ee635a8ebfc5bb38c"

  bottle do
    sha256 "e2387b76b95e32bf97a0f1433eb882225b2d027eb4c3717a37afc463225a885b" => :tiger_altivec
  end

  keg_only :provided_by_osx

  depends_on "openssl"

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


class Libofx < Formula
  desc "Library to support OFX command responses"
  homepage "http://libofx.sourceforge.net"
  url "https://downloads.sourceforge.net/project/libofx/libofx/0.9.9/libofx-0.9.9.tar.gz"
  sha256 "94ef88c5cdc3e307e473fa2a55d4a05da802ee2feb65c85c63b9019c83747b23"


  depends_on "open-sp"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

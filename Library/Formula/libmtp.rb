class Libmtp < Formula
  desc "Implementation of Microsoft's Media Transfer Protocol (MTP)"
  homepage "http://libmtp.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/libmtp/libmtp/1.1.9/libmtp-1.1.9.tar.gz"
  sha256 "23f1d3c0b54107388bf2824d56415e9e087c980c86e5d179865652c022b6b189"


  depends_on "pkg-config" => :build
  depends_on "libusb-compat"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-mtpz"
    system "make", "install"
  end
end

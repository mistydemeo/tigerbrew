class Libcmph < Formula
  desc "C minimal perfect hashing library"
  homepage "http://cmph.sourceforge.net"
  url "https://downloads.sourceforge.net/project/cmph/cmph/cmph-2.0.tar.gz"
  sha256 "ad6c9a75ff3da1fb1222cac0c1d9877f4f2366c5c61c92338c942314230cba76"


  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end

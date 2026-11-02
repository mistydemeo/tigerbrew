class Libnet < Formula
  desc "C library for creating IP packets"
  homepage "https://codedocs.xyz/libnet/libnet/"
  url "https://github.com/libnet/libnet/releases/download/v1.3/libnet-1.3.tar.gz"
  sha256 "ad1e2dd9b500c58ee462acd839d0a0ea9a2b9248a1287840bc601e774fb6b28f"

  bottle do
    cellar :any
  end

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end


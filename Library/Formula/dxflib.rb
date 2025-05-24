class Dxflib < Formula
  desc "C++ library for parsing DXF files"
  homepage "http://www.ribbonsoft.com/en/what-is-dxflib"
  url "http://www.ribbonsoft.com/archives/dxflib/dxflib-2.5.0.0-1.src.tar.gz"
  sha256 "20ad9991eec6b0f7a3cc7c500c044481a32110cdc01b65efa7b20d5ff9caefa9"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end

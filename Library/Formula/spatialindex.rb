class Spatialindex < Formula
  desc "General framework for developing spatial indices"
  homepage "https://libspatialindex.github.io"
  url "http://download.osgeo.org/libspatialindex/spatialindex-src-1.8.5.tar.gz"
  sha256 "7caa46a2cb9b40960f7bc82c3de60fa14f8f3e000b02561b36cbf2cfe6a9bfef"


  def install
    system "./configure", "--disable-debug", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

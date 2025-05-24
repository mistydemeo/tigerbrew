class Libgeotiff < Formula
  desc "Library and tools for dealing with GeoTIFF"
  homepage "http://geotiff.osgeo.org/"
  url "http://download.osgeo.org/geotiff/libgeotiff/libgeotiff-1.4.1.tar.gz"
  sha256 "acfc76ee19b3d41bb9c7e8b780ca55d413893a96c09f3b27bdb9b2573b41fd23"
  revision 2


  depends_on "libtiff"
  depends_on "lzlib"
  depends_on "jpeg"
  depends_on "proj"

  def install
    args = ["--disable-dependency-tracking", "--prefix=#{prefix}",
            "--with-libtiff=#{HOMEBREW_PREFIX}",
            "--with-zlib=#{HOMEBREW_PREFIX}",
            "--with-jpeg=#{HOMEBREW_PREFIX}"]
    system "./configure", *args
    system "make" # Separate steps or install fails
    system "make", "install"
  end
end

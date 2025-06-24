class Libsvg < Formula
  desc "Library for SVG files"
  homepage "http://cairographics.org/"
  url "http://cairographics.org/snapshots/libsvg-0.1.4.tar.gz"
  sha256 "4c3bf9292e676a72b12338691be64d0f38cd7f2ea5e8b67fbbf45f1ed404bc8f"
  revision 2


  depends_on "libpng"
  depends_on "pkg-config" => :build
  depends_on "jpeg"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end

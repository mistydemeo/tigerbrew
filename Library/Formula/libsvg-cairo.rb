class LibsvgCairo < Formula
  desc "SVG rendering library using Cairo"
  homepage "http://cairographics.org/"
  url "http://cairographics.org/snapshots/libsvg-cairo-0.1.6.tar.gz"
  sha256 "a380be6a78ec2938100ce904363815a94068fca372c666b8cc82aa8711a0215c"
  revision 1


  depends_on "pkg-config" => :build
  depends_on "libsvg"
  depends_on "libpng"
  depends_on "cairo"

  def install
    system "./configure", "--disable-dependency-tracking", "--disable-debug",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

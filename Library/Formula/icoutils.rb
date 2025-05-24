class Icoutils < Formula
  desc "Create and extract MS Windows icons and cursors"
  homepage "http://www.nongnu.org/icoutils/"
  url "http://savannah.nongnu.org/download/icoutils/icoutils-0.31.0.tar.bz2"
  sha256 "a895d9d74a418d65d39a667e58ae38be79c9e726711384551d36531696f3af71"
  revision 1


  depends_on "libpng"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-rpath",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/icotool", "-l", test_fixtures("test.ico")
  end
end

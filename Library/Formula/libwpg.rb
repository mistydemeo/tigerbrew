class Libwpg < Formula
  desc "Library for reading and parsing Word Perfect Graphics format"
  homepage "http://libwpg.sourceforge.net/"
  url "http://dev-www.libreoffice.org/src/libwpg-0.3.0.tar.bz2"
  sha256 "28fc3580228a82948dfc01d07abd5076c8b0df76a68702c1a81eb88fdf377348"


  depends_on "pkg-config" => :build
  depends_on "libwpd"
  depends_on "librevenge"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <libwpg/libwpg.h>
      int main() {
        return libwpg::WPG_AUTODETECT;
      }
    EOS
    system ENV.cc, "test.cpp", "-o", "test",
                   "-lrevenge-0.0", "-I#{Formula["librevenge"].include}/librevenge-0.0",
                   "-lwpg-0.3", "-I#{include}/libwpg-0.3"
    system "./test"
  end
end

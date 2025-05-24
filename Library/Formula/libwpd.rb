class Libwpd < Formula
  desc "General purpose library for reading WordPerfect files"
  homepage "http://libwpd.sourceforge.net/"
  url "http://dev-www.libreoffice.org/src/libwpd-0.10.0.tar.bz2"
  sha256 "f2bf5d65156a351ce404550dd822c8db8ab8740b393f61dba828d1b2cb33fe91"


  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "libgsf"
  depends_on "librevenge"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <libwpd/libwpd.h>
      int main() {
        return libwpd::WPD_OK;
      }
    EOS
    system ENV.cc, "test.cpp", "-o", "test",
                   "-lrevenge-0.0", "-I#{Formula["librevenge"].include}/librevenge-0.0",
                   "-lwpd-0.10", "-I#{include}/libwpd-0.10"
    system "./test"
  end
end

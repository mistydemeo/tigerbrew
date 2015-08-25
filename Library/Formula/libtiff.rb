class Libtiff < Formula
  desc "TIFF library and utilities"
  homepage "http://www.remotesensing.org/libtiff/"
  url "http://download.osgeo.org/libtiff/tiff-4.0.4.tar.gz"
  mirror "ftp://ftp.remotesensing.org/pub/libtiff/tiff-4.0.4.tar.gz"
  sha256 "8cb1d90c96f61cdfc0bcf036acc251c9dbe6320334da941c7a83cfe1576ef890"

  bottle do
    cellar :any
    sha256 "e9f63af896016be41844ae294c4a66beeec4d8b919029e5db7e188597be31bae" => :tiger_altivec
    sha256 "421f49dfe37be130936101dd5715953abf4ef5e071b233253a022de97f4f11eb" => :leopard_g3
    sha256 "cd30e46fe20c72913eded0c8d20ac61d2d9b76f70d5f031d6f8470d21a2ce282" => :leopard_altivec
  end

  option :universal
  option :cxx11

  depends_on "jpeg"

  def install
    ENV.universal_binary if build.universal?
    ENV.cxx11 if build.cxx11?
    jpeg = Formula["jpeg"].opt_prefix
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-x",
                          "--disable-lzma",
                          "--with-jpeg-include-dir=#{jpeg}/include",
                          "--with-jpeg-lib-dir=#{jpeg}/lib"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <tiffio.h>

      int main(int argc, char* argv[])
      {
        TIFF *out = TIFFOpen(argv[1], "w");
        TIFFSetField(out, TIFFTAG_IMAGEWIDTH, (uint32) 10);
        TIFFClose(out);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-ltiff", "-o", "test"
    system "./test", "test.tif"
    assert_match /ImageWidth.*10/, shell_output("#{bin}/tiffdump test.tif")
  end
end

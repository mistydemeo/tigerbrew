class Libtiff < Formula
  desc "TIFF library and utilities"
  homepage "https://libtiff.gitlab.io/libtiff/"
  url "https://download.osgeo.org/libtiff/tiff-4.5.0.tar.xz"
  sha256 "dafac979c5e7b6c650025569c5a4e720995ba5f17bc17e6276d1f12427be267c"

  bottle do
    sha256 "081c25de5d538d2cda0919bb3dcaa48b806aa5d8663ad9a6a78df39a8acabec1" => :tiger_altivec
  end

  option :universal
  option :cxx11

  depends_on "jpeg"
  depends_on "xz"
  depends_on "zlib"

  def install
    ENV.universal_binary if build.universal?
    ENV.cxx11 if build.cxx11?
    jpeg = Formula["jpeg"].opt_prefix
    xz = Formula["xz"].opt_prefix
    zlib = Formula["zlib"].opt_prefix
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-x",
                          "--with-jpeg-include-dir=#{jpeg}/include",
                          "--with-jpeg-lib-dir=#{jpeg}/lib",
                          "--with-lzma-include-dir=#{xz}/include",
                          "--with-lzma-lib-dir=#{xz}/lib",
                          "--with-zlib-include-dir=#{zlib}/include",
                          "--with-zlib-lib-dir=#{zlib}/lib"
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

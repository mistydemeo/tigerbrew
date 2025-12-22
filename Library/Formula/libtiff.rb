class Libtiff < Formula
  desc "TIFF library and utilities"
  homepage "https://libtiff.gitlab.io/libtiff/"
  url "https://download.osgeo.org/libtiff/tiff-4.7.1.tar.xz"
  sha256 "b92017489bdc1db3a4c97191aa4b75366673cb746de0dce5d7a749d5954681ba"

  bottle do
    cellar :any
    sha256 "82386e0a89d00e3ef3e03d681b05c5d6ff97561f97ceac8c47222a398254aad0" => :tiger_g3
  end

  option :universal
  option :cxx11

  depends_on "jpeg"
  depends_on "xz"
  depends_on "zlib"

  fails_with :gcc_4_0 if MacOS.version == :tiger && Hardware::CPU.intel? do
    cause "libtiff/tif_lzw.c calls ___builtin_bswap32() on i386 builds with GCC and that's missing from v4.0 here"
  end

  def install
    # tif_dir.c:855: error: for loop initial declaration used outside C99 mode
    # tif_dir.c:874: error: for loop initial declaration used outside C99 mode
    ENV.append "CFLAGS", "-std=gnu99"

    ENV.universal_binary if build.universal?
    ENV.cxx11 if build.cxx11?
    jpeg = Formula["jpeg"].opt_prefix
    xz = Formula["xz"].opt_prefix
    zlib = Formula["zlib"].opt_prefix
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
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

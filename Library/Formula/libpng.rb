class Libpng < Formula
  desc "Library for manipulating PNG images"
  homepage "http://www.libpng.org/pub/png/libpng.html"
  url "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.45/libpng-1.6.45.tar.xz"
  sha256 "926485350139ffb51ef69760db35f78846c805fef3d59bfdcb2fba704663f370"
  license "libpng-2.0"

  head do
    url "https://github.com/glennrp/libpng.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  bottle do
    sha256 "b176b2d5c285cdddffd2532b326e770c299aea3d05e13ccb1428bd0e428d7dfe" => :tiger_altivec
  end

  depends_on "zlib"
  keg_only :provided_pre_mountain_lion

  option :universal

  # pngvalid: read: truecolour+tRNS 8 bit: transform: +rgb_to_gray^0.55556: red/gray output value error: rgba(2,93,95,255): 80 expected: 82 (80.714..82.500)
  # pngvalid: 1 errors, 0 warnings
  # FAIL: pngvalid --strict --transform (floating point arithmetic)
  # FAIL tests/pngvalid-transform (exit status: 1)
  fails_with :clang do
    build 500
    cause "tests/pngvalid-transform fails due to error in floating point arithmetic"
  end

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--with-zlib-prefix=#{Formula["zlib"].opt_prefix}",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "test"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <png.h>

      int main()
      {
        png_structp png_ptr;
        png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lpng", "-o", "test"
    system "./test"
  end
end

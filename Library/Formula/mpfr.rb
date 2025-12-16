class Mpfr < Formula
  desc "C library for multiple-precision floating-point computations"
  homepage "http://www.mpfr.org/"
  url "https://www.mpfr.org/mpfr-4.2.2/mpfr-4.2.2.tar.xz"
  mirror "https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.2.tar.xz"
  sha256 "b67ba0383ef7e8a8563734e2e889ef5ec3c3b898a01d00fa0a6869ad81c6ce01"

  bottle do
    cellar :any
  end

  option "32-bit"
  option "with-tests", "Build and run the test suite"

  depends_on "gmp"

  def install
    ENV.m32 if build.build_32_bit?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules"
    system "make"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gmp.h>
      #include <mpfr.h>

      int main()
      {
        mpfr_t x;
        mpfr_init(x);
        mpfr_clear(x);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{HOMEBREW_PREFIX}/lib", "-lgmp", "-lmpfr", "-o", "test"
    system "./test"
  end
end

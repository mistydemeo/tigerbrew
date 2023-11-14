class Mpfr < Formula
  desc "C library for multiple-precision floating-point computations"
  homepage "http://www.mpfr.org/"
  url "https://www.mpfr.org/mpfr-4.2.1/mpfr-4.2.1.tar.xz"
  mirror "https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz"
  sha256 "277807353a6726978996945af13e52829e3abd7a9a5b7fb2793894e18f1fcbb2"

  bottle do
    cellar :any
    sha256 "2be468ac995cbad3fa75c17a7fc41b2967c52591434124de10420b823fc95aa6" => :tiger_altivec
  end

  option "32-bit"

  depends_on "gmp"

  def install
    ENV.m32 if build.build_32_bit?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules"
    system "make"
    system "make", "check"
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

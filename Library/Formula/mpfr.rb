class Mpfr < Formula
  desc "C library for multiple-precision floating-point computations"
  homepage "http://www.mpfr.org/"
  url "https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.6.tar.xz"
  mirror "https://ftpmirror.gnu.org/mpfr/mpfr-3.1.6.tar.xz"
  sha256 "7a62ac1a04408614fccdc506e4844b10cf0ad2c2b1677097f8f35d3a1344a950"

  bottle do
    cellar :any
    sha256 "d40ac2276bc18b7b26170eed452b35707b1dc1ebba5add0244ad5c71c434b3fc" => :tiger_g4e
    sha256 "194b05ca38b1828ae7c77c3038433459c12249170f76d74af86b71d313b3ec04" => :leopard_g4e
  end

  option "32-bit"

  depends_on "gmp"

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      clang build 421 segfaults while building in superenv;
      see https://github.com/Homebrew/homebrew/issues/15061
      EOS
  end

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
    system ENV.cc, "test.c", "-lgmp", "-lmpfr", "-o", "test"
    system "./test"
  end
end

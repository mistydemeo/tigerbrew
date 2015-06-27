class Mpfr < Formula
  desc "C library for multiple-precision floating-point computations"
  homepage "http://www.mpfr.org/"
  # Upstream is down a lot, so use the GNU mirror + Gist for patches
  url "http://ftpmirror.gnu.org/mpfr/mpfr-3.1.2.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.2.tar.bz2"
  sha256 "79c73f60af010a30a5c27a955a1d2d01ba095b72537dab0ecaad57f5a7bb1b6b"
  version "3.1.2-p11"

  bottle do
    cellar :any
    sha256 "3b44751d4973b19aeef7e677b13fd6e485bafd679958ec97fe54b0018272af45" => :tiger_altivec
    sha256 "dc76f5632de09dc146e7ea882c543e6e66e52c9edc96ce59d09c7d295dbca23c" => :leopard_g3
    sha256 "027026c392c85a50fe467a31bf3bc82b239f5e6eb65ef60ce0bd97a5fc0fc405" => :leopard_altivec
  end

  # http://www.mpfr.org/mpfr-current/allpatches
  patch do
    url "https://gist.githubusercontent.com/jacknagel/7f276cd60149a1ffc9a7/raw/98bd4a4d77d57d91d501e66af2237dfa41b12719/mpfr-3.1.2-p11.diff"
    sha256 "ef758e28d988180ce4e91860a890bab74a5ef2a0cd57b1174c59a6e81d4f5c64"
  end

  depends_on "gmp"

  option "32-bit"

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      clang build 421 segfaults while building in superenv;
      see https://github.com/Homebrew/homebrew/issues/15061
      EOS
  end

  def install
    ENV.m32 if build.build_32_bit?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
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

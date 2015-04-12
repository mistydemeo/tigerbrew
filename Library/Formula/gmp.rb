class Gmp < Formula
  homepage "http://gmplib.org/"
  url "http://ftpmirror.gnu.org/gmp/gmp-6.0.0a.tar.bz2"
  mirror "ftp://ftp.gmplib.org/pub/gmp/gmp-6.0.0a.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.bz2"
  sha256 "7f8e9a804b9c6d07164cf754207be838ece1219425d64e28cfa3e70d5c759aaf"

  bottle do
    cellar :any
    sha1 "954d513d362b0bda155bd8bf0347a49a93e3f885" => :tiger_altivec
    sha1 "ef404f79249e760443a037cc5f9374df4074f8fc" => :leopard_g3
    sha1 "f6b2011e9b1a6e22ccbb30f6ed94d338063feb30" => :leopard_altivec
  end

  option "32-bit"
  option :cxx11

  # https://github.com/mistydemeo/tigerbrew/issues/212
  env :std

  def install
    ENV.cxx11 if build.cxx11?
    args = ["--prefix=#{prefix}", "--enable-cxx"]

    if build.build_32_bit?
      ENV.m32
      args << "ABI=32"
    end

    ENV.append_to_cflags "-force_cpusubtype_ALL" if Hardware.cpu_type == :ppc
    # https://github.com/Homebrew/homebrew/issues/20693
    args << "--disable-assembly" if build.build_32_bit? || build.bottle?

    system "./configure", *args
    system "make"
    system "make", "check"
    ENV.deparallelize
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gmp.h>

      int main()
      {
        mpz_t integ;
        mpz_init (integ);
        mpz_clear (integ);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lgmp", "-o", "test"
    system "./test"
  end
end

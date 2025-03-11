class Libmpc < Formula
  desc "C library for the arithmetic of high precision complex numbers"
  homepage "http://multiprecision.org"
  url "https://ftpmirror.gnu.org/mpc/mpc-1.3.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"
  mirror "https://www.multiprecision.org/downloads/mpc-1.3.1.tar.gz"
  sha256 "ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8"

  bottle do
    cellar :any
    sha256 "91849971ef740d8abcf09becff9c7500afb861edc4f23db3373a36c1c8782185" => :tiger_altivec
  end

  depends_on "gmp"
  depends_on "mpfr"

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}"
    ]

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <mpc.h>

      int main()
      {
        mpc_t x;
        mpc_init2 (x, 256);
        mpc_clear (x);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lgmp", "-lmpfr", "-lmpc", "-o", "test"
    system "./test"
  end
end

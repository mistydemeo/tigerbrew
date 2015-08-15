class Libmpc < Formula
  desc "C library for the arithmetic of high precision complex numbers"
  homepage "http://multiprecision.org"
  url "http://ftpmirror.gnu.org/mpc/mpc-1.0.3.tar.gz"
  mirror "http://multiprecision.org/mpc/download/mpc-1.0.3.tar.gz"
  sha256 "617decc6ea09889fb08ede330917a00b16809b8db88c29c31bfbb49cbf88ecc3"

  bottle do
    cellar :any
    sha256 "e6f5407e707bdda02cd56365ffc06840739e1ce12cb26a42f84cfd94a2b8380b" => :tiger_altivec
    sha256 "e1d5665aa0ee5311993ba4dc64200aec82421b6d157403de9309f1930aad19c7" => :leopard_g3
    sha256 "6bf27cc9799fd7737c0a3dac7c8d65c87a5db6f7feaffb271a0d4c838061342f" => :leopard_altivec
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

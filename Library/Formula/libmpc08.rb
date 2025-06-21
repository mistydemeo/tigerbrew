class Libmpc08 < Formula
  desc "C library for high precision complex numbers"
  homepage "https://web.archive.org/web/20250617204647/http://www.multiprecision.org/"
  url "https://www.multiprecision.org/downloads/mpc-0.8.2.tar.gz"
  mirror "https://ftp2.osuosl.org/pub/clfs/conglomeration/mpc/mpc-0.8.2.tar.gz"
  sha256 "ae79f8d41d8a86456b68607e9ca398d00f8b7342d1d83bcf4428178ac45380c7"

  bottle do
    cellar :any
  end

  keg_only "Conflicts with libmpc in main repository."

  depends_on "gmp4"
  depends_on "mpfr2"

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--with-gmp=#{Formula["gmp4"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr2"].opt_prefix}",
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
    gmp4 = Formula["gmp4"]
    mpfr2 = Formula["mpfr2"]
    system ENV.cc, "test.c",
      "-I#{gmp4.include}", "-L#{gmp4.lib}", "-lgmp",
      "-I#{mpfr2.include}", "-L#{mpfr2.lib}", "-lmpfr",
      "-I#{include}", "-L#{lib}", "-lmpc",
      "-o", "test"
    system "./test"
  end
end

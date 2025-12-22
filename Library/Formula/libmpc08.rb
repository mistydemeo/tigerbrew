class Libmpc08 < Formula
  desc "C library for high precision complex numbers"
  homepage "http://multiprecision.org"
  url "https://www.multiprecision.org/downloads/mpc-0.8.2.tar.gz"
  mirror "https://ftp2.osuosl.org/pub/clfs/conglomeration/mpc/mpc-0.8.2.tar.gz"
  sha256 "ae79f8d41d8a86456b68607e9ca398d00f8b7342d1d83bcf4428178ac45380c7"

  bottle do
    cellar :any
    sha256 "fefb74bd5fea450721e92024da3cdf167b2e1949252e36a27b64935d71665413" => :tiger_g3
  end

  keg_only "Conflicts with libmpc in main repository."

  option "with-tests", "Build and run the test suite"

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
    system "make", "check" if build.with?("tests") || build.bottle?
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

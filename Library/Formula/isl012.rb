class Isl012 < Formula
  desc "Integer Set Library for the polyhedral model"
  homepage "https://libisl.sourceforge.io"
  # Track gcc infrastructure releases.
  url "https://libisl.sourceforge.io/isl-0.12.2.tar.bz2"
  mirror "https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.12.2.tar.bz2"
  sha256 "f4b3dbee9712850006e44f0db2103441ab3d13b406f77996d1df19ee89d11fb4"

  bottle do
    cellar :any
    sha256 "3e319d98345148da64db9b333bb705d83c99ea0519783bb34482a048b4eac3e5" => :tiger_altivec
  end

  keg_only "Conflicts with isl in main repository."

  option "with-tests", "Build and run the test suite"

  depends_on "gmp4"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula["gmp4"].opt_prefix}"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
    (share/"gdb/auto-load").install Dir["#{lib}/*-gdb.py"]
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <isl/ctx.h>

      int main()
      {
        isl_ctx* ctx = isl_ctx_alloc();
        isl_ctx_free(ctx);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lisl",
      "-I#{include}", "-I#{Formula["gmp4"].include}", "-o", "test"
    system "./test"
  end
end

class Isl011 < Formula
  desc "Integer Set Library for the polyhedral model"
  homepage "https://libisl.sourceforge.io"
  # Track gcc infrastructure releases.
  url "https://libisl.sourceforge.io/isl-0.11.1.tar.bz2"
  mirror "https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.11.1.tar.bz2"
  sha256 "095f4b54c88ca13a80d2b025d9c551f89ea7ba6f6201d701960bfe5c1466a98d"

  bottle do
    cellar :any
    sha256 "aa1a49f3bf7e60949fa5ad73aceeb3b29b907df363ac2e359bff8a709e4aa7aa" => :tiger_altivec
  end

  keg_only "Conflicts with isl in main repository."

  depends_on "gmp4"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula["gmp4"].opt_prefix}"
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

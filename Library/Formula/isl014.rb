class Isl014 < Formula
  desc "Integer Set Library for the polyhedral model"
  homepage "https://libisl.sourceforge.io"
  # Track gcc infrastructure releases.
  url "https://libisl.sourceforge.io/isl-0.14.tar.bz2"
  mirror "https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.14.tar.bz2"
  sha256 "7e3c02ff52f8540f6a85534f54158968417fd676001651c8289c705bd0228f36"

  bottle do
    cellar :any
    sha256 "447b6287056265142d0259370f9b1187362dd33d800c68d9dea3a23221559007" => :tiger_altivec
  end

  keg_only "Conflicts with isl in main repository."

  depends_on "gmp"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula["gmp"].opt_prefix}"
    system "make"
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
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lisl", "-o", "test"
    system "./test"
  end
end

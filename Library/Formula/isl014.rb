class Isl014 < Formula
  desc "Integer Set Library for the polyhedral model"
  homepage "http://freecode.com/projects/isl"
  # Track gcc infrastructure releases.
  url "http://isl.gforge.inria.fr/isl-0.14.tar.bz2"
  mirror "ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.14.tar.bz2"
  sha256 "7e3c02ff52f8540f6a85534f54158968417fd676001651c8289c705bd0228f36"

  bottle do
    cellar :any
    sha256 "a6166d161841d901af54319a5434e955964712ae5cc19a88705d4f28669dc36b" => :yosemite
    sha256 "cbcb2862709fa87913927a3ce261ac989f650a3506abde6c9eaa4da2d58b2b53" => :mavericks
    sha256 "04997936c670ba1289574c526a62c69eae7e82c94c20b680df2f995df83b6d59" => :mountain_lion
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

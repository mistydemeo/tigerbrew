class Isl011 < Formula
  desc "Integer Set Library for the polyhedral model"
  homepage "https://libisl.sourceforge.io"
  # Track gcc infrastructure releases.
  url "https://libisl.sourceforge.io/isl-0.11.2.tar.bz2"
  sha256 "e6d83347d254449577299ec86ffefd79361dc51f6de7480723c9c43b075cdc23"

  bottle do
    cellar :any
    sha256 "dd70c4834b102c27c19989db5ebbaf0bc9be361b94c3a9a6fd713cbb317c28a8" => :tiger_altivec
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

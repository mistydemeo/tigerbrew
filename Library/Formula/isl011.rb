class Isl011 < Formula
  desc "Integer Set Library for the polyhedral model"
  homepage "http://freecode.com/projects/isl"
  # Track gcc infrastructure releases.
  url "http://isl.gforge.inria.fr/isl-0.11.1.tar.bz2"
  mirror "ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.11.1.tar.bz2"
  sha256 "095f4b54c88ca13a80d2b025d9c551f89ea7ba6f6201d701960bfe5c1466a98d"

  bottle do
    cellar :any
    revision 1
    sha256 "13e867965cd3a068d7261b4f07cb9835f8f3e4661f27d151318a3b04fccacbd0" => :el_capitan
    sha256 "6d59cb6e7fc0aa67ff5a0734d00aaf712f424dcd6094f29b0dbbfa5d5f205a98" => :yosemite
    sha256 "d747feae5b551c03d783886fd3aa58a86ce04a73753d1d8347b196f953d54ddd" => :mavericks
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

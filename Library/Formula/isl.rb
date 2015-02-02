class Isl < Formula
  homepage "http://freecode.com/projects/isl"
  # Note: Always use tarball instead of git tag for stable version.
  #
  # Currently isl detects its version using source code directory name
  # and update isl_version() function accordingly.  All other names will
  # result in isl_version() function returning "UNKNOWN" and hence break
  # package detection.
  #
  # 0.13 is out, but we can't upgrade until a compatible version of cloog is
  # released.
  url "http://isl.gforge.inria.fr/isl-0.12.2.tar.bz2"
  sha1 "ca98a91e35fb3ded10d080342065919764d6f928"

  bottle do
    cellar :any
    sha1 "b75c971058946c3a261a7cb807fc032644b8337b" => :tiger_altivec
    sha1 "13905e3263d3b3218aaa590bb767a0de5653ff14" => :leopard_g3
    sha1 "5a48c443a0a3a67335843346217138073fdf074c" => :leopard_altivec
  end

  head do
    url "http://repo.or.cz/r/isl.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "gmp"

  def install
    system "./autogen.sh" if build.head?
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
    system ENV.cc, "test.c", "-lisl", "-o", "test"
    system "./test"
  end
end

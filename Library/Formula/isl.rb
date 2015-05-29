class Isl < Formula
  homepage "http://freecode.com/projects/isl"
  # Note: Always use tarball instead of git tag for stable version.
  #
  # Currently isl detects its version using source code directory name
  # and update isl_version() function accordingly.  All other names will
  # result in isl_version() function returning "UNKNOWN" and hence break
  # package detection.
  url "http://isl.gforge.inria.fr/isl-0.14.1.tar.xz"
  sha256 "8882c9e36549fc757efa267706a9af733bb8d7fe3905cbfde43e17a89eea4675"

  bottle do
    cellar :any
    sha256 "5eaa78e68bc8d075525deb825a6eb06c2fb50a17b7dd4396ad0ac55de8aa3756" => :tiger_altivec
    sha256 "9b9a2b0962c3ebfcabe04a59ea55b4ca27c78399f8da2b13b9e87d5b6af204c3" => :leopard_g3
    sha256 "2aec4bfbb99d9d8f8946f38ba7a047a51ad6cae6332699305dca79f702ca322a" => :leopard_altivec
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

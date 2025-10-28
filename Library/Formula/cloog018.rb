class Cloog018 < Formula
  desc "Generate code for scanning Z-polyhedra"
  homepage "http://www.cloog.org/"
  # Need a minimum of isl 0.12 with v0.18.3 onwards.
  url "http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-0.18.1.tar.gz"
  mirror "https://www.mirrorservice.org/sites/sourceware.org/pub/gcc/infrastructure/cloog-0.18.1.tar.gz"
  mirror "https://gcc.gnu.org/pub/gcc/infrastructure/cloog-0.18.1.tar.gz"
  sha256 "02500a4edd14875f94fe84cbeda4290425cb0c1c2474c6f75d75a303d64b4196"

  bottle do
    cellar :any
    sha256 "f5f3f243e94fcfcc055b384fc2a95262335946a0a8387ba2a4147d4f0a322a38" => :tiger_altivec
  end

  keg_only "Conflicts with cloog in main repository."

  depends_on "pkg-config" => :build
  depends_on "gmp4"
  depends_on "isl011"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--with-bits=gmp",
                          "--with-gmp-prefix=#{Formula["gmp4"].opt_prefix}",
                          "--with-isl=system",
                          "--with-isl-exec-prefix==#{Formula["isl011"].opt_lib}"
                          "--with-isl-prefix=#{Formula["isl011"].opt_include}"
    system "make", "install"
  end

  test do
    cloog_source = <<-EOS.undent
      c

      0 2
      0

      1

      1
      0 2
      0 0 0
      0

      0
    EOS

    assert_match "Generated from /dev/stdin by CLooG",
      pipe_output("#{bin}/cloog /dev/stdin", cloog_source)
  end
end

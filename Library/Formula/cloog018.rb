class Cloog018 < Formula
  desc "Generate code for scanning Z-polyhedra"
  homepage "http://www.cloog.org/"
  # Track gcc infrastructure releases.
  url "http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-0.18.0.tar.gz"
  mirror "https://www.mirrorservice.org/sites/sourceware.org/pub/gcc/infrastructure/cloog-0.18.0.tar.gz"
  mirror "https://gcc.gnu.org/pub/gcc/infrastructure/cloog-0.18.0.tar.gz"
  sha256 "1c4aa8dde7886be9cbe0f9069c334843b21028f61d344a2d685f88cb1dcf2228"

  bottle do
    cellar :any
  end

  keg_only "Conflicts with cloog in main repository."

  depends_on "pkg-config" => :build
  depends_on "gmp4"
  depends_on "isl011"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--with-gmp-prefix=#{Formula["gmp4"].opt_prefix}",
                          "--with-isl-prefix=#{Formula["isl011"].opt_prefix}"
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

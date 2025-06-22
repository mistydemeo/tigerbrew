class CloogPpl015 < Formula
  homepage "https://repo.or.cz/w/cloog-ppl.git"
  url "https://gcc.gnu.org/pub/gcc/infrastructure/cloog-ppl-0.15.11.tar.gz"
  mirror "https://www.mirrorservice.org/sites/sourceware.org/pub/gcc/infrastructure/cloog-ppl-0.15.11.tar.gz"
  sha256 "7cd634d0b2b401b04096b545915ac67f883556e9a524e8e803a6bf6217a84d5f"

  bottle do
    sha256 "0ce866bba1f69e724c68c2c35be6fb4b9588cc19b91525c4d208488b238f423b" => :tiger_altivec
  end

  keg_only "Conflicts with cloog in main repository."

  depends_on "gmp4"
  depends_on "ppl011"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-gmp=#{Formula["gmp4"].opt_prefix}"
      --with-ppl=#{Formula["ppl011"].opt_prefix}"
    ]

    system "./configure", *args
    system "make", "install"
  end
end

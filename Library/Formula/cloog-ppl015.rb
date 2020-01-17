class CloogPpl015 < Formula
  homepage "http://repo.or.cz/w/cloog-ppl.git"
  url "ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-ppl-0.15.11.tar.gz"
  mirror "http://gcc.cybermirror.org/infrastructure/cloog-ppl-0.15.11.tar.gz"
  sha256 "7cd634d0b2b401b04096b545915ac67f883556e9a524e8e803a6bf6217a84d5f"

  bottle do
    cellar :any
    sha256 "e80958bc126358051c2c40ba8b12aae5fa2e55a086dd103241f7469a6812df29" => :yosemite
    sha256 "e18498773771e61e533c1521212ad4f2be43f62b5c00478c89fc52934850450f" => :mavericks
    sha256 "ff20e10aa53c2650de8f008d8b6cd803ed1960e6d88282574c2217700ba0a81f" => :mountain_lion
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

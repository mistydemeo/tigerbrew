class Depqbf < Formula
  desc "Solver for quantified boolean formulae (QBF)"
  homepage "https://lonsing.github.io/depqbf/"
  url "https://github.com/lonsing/depqbf/archive/version-4.01.tar.gz"
  sha256 "0246022128890d24b926a9bd17a9d4aa89b179dc05a0fedee33fa282c0ceba5b"
  head "https://github.com/lonsig/depqbf.git"


  def install
    system "make"
    bin.install "depqbf"
    lib.install "libqdpll.1.0.dylib"
  end

  test do
    system "#{bin}/depqbf", "-h"
  end
end

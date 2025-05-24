require "language/haskell"

class Texmath < Formula
  include Language::Haskell::Cabal

  desc "Haskell library for converting LaTeX math to MathML"
  homepage "http://johnmacfarlane.net/texmath.html"
  url "https://hackage.haskell.org/package/texmath-0.8.0.2/texmath-0.8.0.2.tar.gz"
  sha256 "47b9c3fdceed63c5d63987db7e511a38ea8ddf8591786ef56efea734a3c31f86"

  revision 1


  depends_on "ghc" => :build
  depends_on "cabal-install" => :build

  setup_ghc_compilers

  def install
    cabal_sandbox do
      cabal_install "--only-dependencies"
      cabal_install "--prefix=#{prefix}", "-fexecutable"
    end
    cabal_clean_lib
  end

  test do
    assert_match "<mn>2</mn>", pipe_output("texmath", "a^2 + b^2 = c^2")
  end
end

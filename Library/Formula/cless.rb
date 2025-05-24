require "language/haskell"

class Cless < Formula
  include Language::Haskell::Cabal

  desc "Display file contents with colorized syntax highlighting"
  homepage "https://github.com/tanakh/cless"
  url "https://hackage.haskell.org/package/cless-0.3.0.0/cless-0.3.0.0.tar.gz"
  sha256 "0f06437973de1c36c1ac2472091a69c2684db40ba12f881592f1f08e8584629b"

  revision 1


  depends_on "ghc" => :build
  depends_on "cabal-install" => :build

  setup_ghc_compilers

  def install
    # The "--allow-newer" is a hack for GHC 7.10.1, remove when possible.
    install_cabal_package "--allow-newer"
  end

  test do
    system "#{bin}/cless", "--help"
    system "#{bin}/cless", "--list-langs"
    system "#{bin}/cless", "--list-styles"
  end
end

require "language/haskell"

class Darcs < Formula
  include Language::Haskell::Cabal

  desc "Distributed version control system that tracks changes, via Haskell"
  homepage "http://darcs.net/"
  url "http://darcs.net/releases/darcs-2.10.0.tar.gz"
  sha256 "52b3db3f7b64a4306585b96af7b5887f62ba54f6e9c3bdbed9b6a18d97f16b36"


  depends_on "ghc" => :build
  depends_on "cabal-install" => :build
  depends_on "gmp"

  setup_ghc_compilers

  def install
    install_cabal_package
  end

  test do
    mkdir "my_repo" do
      system "darcs", "init"
      (Pathname.pwd/"foo").write "hello homebrew!"
      system "darcs", "add", "foo"
      system "darcs", "record", "-am", "add foo", "--author=homebrew"
    end
    system "darcs", "get", "my_repo", "my_repo_clone"
    Dir.chdir "my_repo_clone" do
      assert (Pathname.pwd/"foo").read.include? "hello homebrew!"
    end
  end
end

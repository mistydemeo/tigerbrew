class CabalInstall < Formula
  desc "Command-line interface for Cabal and Hackage"
  homepage "https://www.haskell.org/cabal/"
  url "https://hackage.haskell.org/package/cabal-install-1.22.6.0/cabal-install-1.22.6.0.tar.gz"
  sha256 "9d239e385696a7faa49f068aea451882baec6a7df26fbddbd08271c9053cb0b4"


  depends_on "ghc"

  fails_with :clang if MacOS.version < :mavericks # Same as ghc.rb

  def install
    system "sh", "bootstrap.sh", "--sandbox"
    bin.install ".cabal-sandbox/bin/cabal"
    bash_completion.install "bash-completion/cabal"
  end

  test do
    system "#{bin}/cabal", "--config-file=#{testpath}/config", "info", "cabal"
  end
end

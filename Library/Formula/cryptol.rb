require "language/haskell"

class Cryptol < Formula
  include Language::Haskell::Cabal

  desc "Domain-specific language for specifying cryptographic algorithms"
  homepage "http://www.cryptol.net/"
  url "https://github.com/GaloisInc/cryptol.git",
      :tag => "v2.2.4",
      :revision => "ebaa98699bfc704c5ac5a100e2829e68f3a11d9b"
  head "https://github.com/GaloisInc/cryptol.git"


  depends_on "ghc" => :build
  depends_on "cabal-install" => :build
  depends_on "cvc4"

  setup_ghc_compilers

  def install
    cabal_sandbox do
      system "make", "PREFIX=#{prefix}", "install"
    end
  end

  test do
    (testpath/"hello.icry").write <<-EOS.undent
      :prove \\(x : [8]) -> x == x
      :prove \\(x : [32]) -> x + zero == x
    EOS
    result = shell_output "#{bin}/cryptol -b #{(testpath/"hello.icry")}"
    expected = <<-EOS.undent
      Loading module Cryptol
      Q.E.D.
      Q.E.D.
    EOS
    assert_match expected, result
  end
end

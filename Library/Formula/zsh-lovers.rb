class ZshLovers < Formula
  desc "Tips, tricks, and examples for zsh"
  homepage "http://grml.org/zsh/#zshlovers"
  url "http://grml.org/zsh/zsh-lovers.1"
  version "0.9.1"
  sha256 "6583aabf4024c951f19a381ce97ce2c7af948b24fc332504c3f719ec9187c72f"

  def install
    man1.install "zsh-lovers.1"
  end
end

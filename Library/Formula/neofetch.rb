class Neofetch < Formula
  desc "Fast, highly customisable system info script"
  homepage "https://github.com/suparious/neofetch"
  url "https://github.com/suparious/neofetch/archive/refs/tags/7.6.1.tar.gz"
  sha256 "bdb1cce707059657177b2fe7d132a2632e316f4bde413be67d4e8524b2a9cae9"
  license "MIT"
  head "https://github.com/suparious/neofetch.git", branch: "master"

  def install
    inreplace "neofetch", "/usr/local", HOMEBREW_PREFIX
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system bin/"neofetch", "--config", "none", "--color_blocks", "off",
                              "--disable", "wm", "de", "term", "gpu"
  end
end

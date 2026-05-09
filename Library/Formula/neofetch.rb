class Neofetch < Formula
  desc "Fast, highly customisable system info script"
  homepage "https://github.com/suparious/neofetch"
  url "https://github.com/suparious/neofetch/archive/refs/tags/7.6.0.tar.gz"
  sha256 "71ffa7f22dbde250f3eeae89728cb70f65e8d1915e9afb1042d78980760e7625"
  license "MIT"
  head "https://github.com/suparious/neofetch.git", branch: "master"

  # on_macos do
  #   depends_on "screenresolution"
  # end

  def install
    inreplace "neofetch", "/usr/local", HOMEBREW_PREFIX
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system bin/"neofetch", "--config", "none", "--color_blocks", "off",
                              "--disable", "wm", "de", "term", "gpu"
  end
end

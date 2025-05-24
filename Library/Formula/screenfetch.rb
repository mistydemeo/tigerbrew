class Screenfetch < Formula
  desc "Generate ASCII art with terminal, shell, and OS info"
  homepage "https://github.com/KittyKatt/screenFetch"
  url "https://github.com/KittyKatt/screenFetch/archive/v3.7.0.tar.gz"
  sha256 "6711fe924833919d53c1dfbbb43f3777d33e20357a1b1536c4472f6a1b3c6be0"
  head "https://github.com/KittyKatt/screenFetch.git", :shallow => false


  def install
    bin.install "screenfetch-dev" => "screenfetch"
    man1.install "screenfetch.1"
  end

  test do
    system "#{bin}/screenfetch"
  end
end

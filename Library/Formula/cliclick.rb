class Cliclick < Formula
  desc "Tool for automating emulated mouse clicks"
  homepage "https://www.bluem.net/jump/cliclick/"
  url "https://github.com/BlueM/cliclick/archive/3.1.tar.gz"
  sha256 "d54273403ea786facb56fa85e8025f8fbf6bd1819ecd4b24625fa110a4ca3bec"


  def install
    system "make"
    bin.install "cliclick"
  end

  test do
    system bin/"cliclick", "p:OK"
  end
end

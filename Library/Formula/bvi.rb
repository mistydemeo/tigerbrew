class Bvi < Formula
  desc "Vi-like binary file (hex) editor"
  homepage "http://bvi.sourceforge.net"
  url "https://downloads.sourceforge.net/bvi/bvi-1.4.0.src.tar.gz"
  sha256 "015a3c2832c7c097d98a5527deef882119546287ba8f2a70c736227d764ef802"


  def install
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make", "install"
  end

  test do
    ENV["TERM"] = "xterm"
    system "#{bin}/bvi", "-c", "q"
  end
end

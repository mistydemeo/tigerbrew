class Tcping < Formula
  desc "TCP connect to the given IP/port combo"
  homepage "http://www.linuxco.de/tcping/tcping.html"
  url "http://www.linuxco.de/tcping/tcping-1.3.5.tar.gz"
  sha256 "1ad52e904094d12b225ac4a0bc75297555e931c11a1501445faa548ff5ecdbd0"


  def install
    system "make"
    bin.install "tcping"
  end

  test do
    system "#{bin}/tcping", "www.google.com", "80"
  end
end

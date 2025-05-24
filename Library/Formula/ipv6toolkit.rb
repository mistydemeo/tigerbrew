class Ipv6toolkit < Formula
  desc "Security assessment and troubleshooting tool for IPv6"
  homepage "http://www.si6networks.com/tools/ipv6toolkit/"
  url "http://www.si6networks.com/tools/ipv6toolkit/ipv6toolkit-v2.0.tar.gz"
  sha256 "16f13d3e7d17940ff53f028ef0090e4aa3a193a224c97728b07ea6e26a19e987"


  def install
    system "make"
    system "make", "install", "DESTDIR=#{prefix}", "PREFIX=", "MANPREFIX=/share"
  end

  test do
    system "#{bin}/addr6", "-a", "fc00::1"
  end
end

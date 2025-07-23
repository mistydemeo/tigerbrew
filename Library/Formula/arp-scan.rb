class ArpScan < Formula
  desc "ARP scanning and fingerprinting tool"
  homepage "http://www.nta-monitor.com/tools-resources/security-tools/arp-scan"
  url "https://github.com/royhills/arp-scan/releases/download/1.10.0/arp-scan-1.10.0.tar.gz"
  sha256 "ce908ac71c48e85dddf6dd4fe5151d13c7528b1f49717a98b2a2535bd797d892"

  bottle do
  end

  head do
    url "https://github.com/royhills/arp-scan.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  depends_on "libpcap"

  def install
    system "autoreconf", "--install" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/arp-scan", "-V"
  end
end

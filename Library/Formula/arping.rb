class Arping < Formula
  desc "Utility to check whether MAC addresses are already taken on a LAN"
  homepage "https://www.habets.pp.se/synscan/programs_arping.html"
  url "https://www.habets.pp.se/synscan/files/arping-2.29.tar.gz"
  mirror "https://github.com/ThomasHabets/arping/archive/refs/tags/arping-2.29.tar.gz"
  sha256 "2ad75204d4aaafd45251c577ddd55c83c39b0b5a3b332b66641a2fea13e68939"

  bottle do
    cellar :any
  end

  depends_on "libnet"
  depends_on "libpcap"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{sbin}/arping", "--help"
  end
end

class Ipinfo < Formula
  desc "Tool for calculation of IP networks"
  homepage "http://kyberdigi.cz/projects/ipinfo/"
  url "http://kyberdigi.cz/projects/ipinfo/files/ipinfo-1.2.tar.gz"
  sha256 "19e6659f781a48b56062a5527ff463a29c4dcc37624fab912d1dce037b1ddf2d"

  bottle do
  end

  def install
    system "make", "BINDIR=#{bin}",
                   "MANDIR=#{man1}",
                   "install"
  end

  test do
    system "ipinfo", "127.0.0.1"
  end
end

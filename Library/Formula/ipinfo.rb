class Ipinfo < Formula
  desc "Tool for calculation of IP networks"
  homepage "http://kyberdigi.cz/projects/ipinfo/"
  url "http://kyberdigi.cz/projects/ipinfo/files/ipinfo-1.2.tar.gz"
  sha256 "19e6659f781a48b56062a5527ff463a29c4dcc37624fab912d1dce037b1ddf2d"

  bottle do
    cellar :any_skip_relocation
    sha256 "60c24c3578e0f1fdb15d9849a723aaf0ea3d88296c124a56cdf2ed49d96d3633" => :tiger_altivec
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

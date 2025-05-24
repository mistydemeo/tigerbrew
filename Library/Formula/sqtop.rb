class Sqtop < Formula
  desc "Display information about active connections for a Squid proxy"
  homepage "https://github.com/paleg/sqtop"
  url "https://github.com/paleg/sqtop/archive/v2015-02-08.tar.gz"
  version "2015-02-08"
  sha256 "eae4c8bc16dbfe70c776d990ecf14328acab0ed736f0bf3bd1647a3ac2f5e8bf"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match "#{version}", shell_output("#{bin}/sqtop --help")
  end
end

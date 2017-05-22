class Miniupnpc < Formula
  desc "UpnP IGD client library and daemon"
  homepage "https://miniupnp.tuxfamily.org"
  url "http://miniupnp.tuxfamily.org/files/download.php?file=miniupnpc-2.0.20170509.tar.gz"
  sha256 "d3c368627f5cdfb66d3ebd64ca39ba54d6ff14a61966dbecb8dd296b7039f16a"

  bottle do
    cellar :any
  end

  def install
    system "make", "INSTALLPREFIX=#{prefix}", "install"
  end
end

class Xhyve < Formula
  desc "xhyve, lightweight OS X virtualization solution based on FreeBSD's bhyve"
  homepage "https://github.com/mist64/xhyve"
  url "https://github.com/mist64/xhyve/archive/v0.2.0.tar.gz"
  sha256 "32c390529a73c8eb33dbc1aede7baab5100c314f726cac14627d2204ad9d3b3c"
  head "https://github.com/mist64/xhyve.git"


  depends_on :macos => :yosemite

  def install
    args = []
    args << "GIT_VERSION=#{version}" if build.stable?
    system "make", *args
    bin.install "build/xhyve"
  end

  test do
    system "#{bin}/xhyve", "-v"
  end
end

class Flvstreamer < Formula
  desc "Stream audio and video from flash & RTMP Servers"
  homepage "http://www.nongnu.org/flvstreamer/"
  url "https://download.savannah.nongnu.org/releases/flvstreamer/source/flvstreamer-2.1c1.tar.gz"
  sha256 "e90e24e13a48c57b1be01e41c9a7ec41f59953cdb862b50cf3e667429394d1ee"

  bottle do
  end

  def install
    system "make", "posix"
    bin.install "flvstreamer", "rtmpsrv", "rtmpsuck", "streams"
  end

  test do
    system "#{bin}/flvstreamer", "-h"
  end
end

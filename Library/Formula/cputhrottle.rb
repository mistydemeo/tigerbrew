class Cputhrottle < Formula
  desc "Limit the CPU usage of a process"
  homepage "http://www.willnolan.com/cputhrottle/cputhrottle.html"
  url "http://www.willnolan.com/cputhrottle/cputhrottle.tar.gz"
  sha256 "fdf284e1c278e4a98417bbd3eeeacf40db684f4e79a9d4ae030632957491163b"
  version "20100515"


  depends_on "boost" => :build

  def install
    system "make", "all"
    bin.install "cputhrottle"
  end
end

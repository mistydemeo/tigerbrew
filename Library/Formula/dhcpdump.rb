class Dhcpdump < Formula
  desc "Monitor DHCP traffic for debugging purposes"
  homepage "https://www.mavetju.org/unix/general.php"
  url "http://www.mavetju.org/download/dhcpdump-1.8.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/d/dhcpdump/dhcpdump_1.8.orig.tar.gz"
  sha256 "6d5eb9418162fb738bc56e4c1682ce7f7392dd96e568cc996e44c28de7f77190"

  bottle do
    cellar :any
    sha256 "6df64653cfd4b118db43e2acb2f08a565ac3cba9e1b739a258eeb7655c1a6103" => :yosemite
    sha256 "c549cb96db8e621b379b1a02cd4e743ff74b4d212f2d880649351e28c4c63684" => :mavericks
    sha256 "bcf2658789655d4c518f9b666e8b46b205b3d1ac8aad3c6057fc0fac28a72cb1" => :mountain_lion
  end

  def install
    system "make"
    bin.install "dhcpdump"
    man8.install "dhcpdump.8"
  end

  test do
    system "#{bin}/dhcpdump", "-h"
  end
end

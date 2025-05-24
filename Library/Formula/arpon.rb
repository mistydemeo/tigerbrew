class Arpon < Formula
  desc "Handler daemon to secure the ARP protocol from MITM attacks"
  homepage "http://arpon.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/arpon/arpon/ArpON-2.7.2.tar.gz"
  sha256 "99adf83e4cdf2eda01601a60e2e1a611b5bce73865745fe67774c525c5f7d6d0"

  head "git://git.code.sf.net/p/arpon/code"


  depends_on "cmake" => :build
  depends_on "libdnet"
  depends_on "libnet"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end

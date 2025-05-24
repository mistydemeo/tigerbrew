class Ipsumdump < Formula
  desc "Summarizes TCP/IP dump files into a self-describing ASCII format easily readable"
  homepage "http://www.read.seas.harvard.edu/~kohler/ipsumdump/"
  url "http://www.read.seas.harvard.edu/~kohler/ipsumdump/ipsumdump-1.85.tar.gz"
  sha256 "98feca0f323605a022ba0cabcd765a8fcad1b308461360a5ae6c4c293740dc32"
  head "https://github.com/kohler/ipsumdump.git"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/ipsumdump", "-c", "-r", "#{test_fixtures("test.pcap")}"
  end
end

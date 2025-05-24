class Libxdiff < Formula
  desc "Implements diff functions for binary and text files"
  homepage "http://www.xmailserver.org/xdiff-lib.html"
  url "http://www.xmailserver.org/libxdiff-0.23.tar.gz"
  sha256 "e9af96174e83c02b13d452a4827bdf47cb579eafd580953a8cd2c98900309124"


  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end
end

class Enet < Formula
  desc "Provides a network communication layer on top of UDP"
  homepage "http://enet.bespin.org"
  url "http://enet.bespin.org/download/enet-1.3.13.tar.gz"
  sha256 "e36072021faa28731b08c15b1c3b5b91b911baf5f6abcc7fe4a6d425abada35c"


  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end

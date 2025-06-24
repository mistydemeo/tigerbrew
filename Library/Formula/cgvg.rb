class Cgvg < Formula
  desc "Command-line source browsing tool"
  homepage "http://www.uzix.org/cgvg.html"
  url "http://www.uzix.org/cgvg/cgvg-1.6.3.tar.gz"
  sha256 "d879f541abcc988841a8d86f0c0781ded6e70498a63c9befdd52baf4649a12f3"


  def install
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end
end

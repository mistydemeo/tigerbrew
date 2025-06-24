class Libowfat < Formula
  desc "Reimplements libdjb"
  homepage "http://www.fefe.de/libowfat/"
  head ":pserver:cvs:@cvs.fefe.de:/cvs", :using => :cvs
  url "http://dl.fefe.de/libowfat-0.29.tar.bz2"
  sha256 "4badbdeed6bef4337f1edd6b86fb7154c5592509c272dcdc09c693161cbc6427"


  def install
    system "make", "libowfat.a"
    system "make", "install", "prefix=#{prefix}", "MAN3DIR=#{man3}", "INCLUDEDIR=#{include}/libowfat"
  end
end

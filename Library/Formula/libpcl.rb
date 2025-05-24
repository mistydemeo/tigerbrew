class Libpcl < Formula
  desc "C library and API for coroutines"
  homepage "http://xmailserver.org/libpcl.html"
  url "http://xmailserver.org/pcl-1.12.tar.gz"
  sha256 "e7b30546765011575d54ae6b44f9d52f138f5809221270c815d2478273319e1a"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

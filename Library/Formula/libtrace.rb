class Libtrace < Formula
  desc "Library for trace processing supporting multiple inputs"
  homepage "http://research.wand.net.nz/software/libtrace.php"
  url "http://research.wand.net.nz/software/libtrace/libtrace-3.0.22.tar.bz2"
  sha256 "b8bbaa2054c69cc8f93066143e2601c09c8ed56e75c6e5e4e2c115d07952f8f8"


  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

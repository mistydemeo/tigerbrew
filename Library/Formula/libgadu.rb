class Libgadu < Formula
  desc "Library for ICQ instant messenger protocol"
  homepage "http://libgadu.net/"
  url "https://github.com/wojtekka/libgadu/releases/download/1.12.1/libgadu-1.12.1.tar.gz"
  sha256 "a2244074a89b587ba545b5d87512d6eeda941fec4a839b373712de93308d5386"


  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug",
                          "--disable-dependency-tracking"
    system "make", "install"
  end
end

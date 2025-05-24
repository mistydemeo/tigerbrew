class Libtecla < Formula
  desc "Command-line editing facilities similar to the tcsh shell"
  homepage "http://www.astro.caltech.edu/~mcs/tecla/index.html"
  url "http://www.astro.caltech.edu/~mcs/tecla/libtecla-1.6.3.tar.gz"
  sha256 "f2757cc55040859fcf8f59a0b7b26e0184a22bece44ed9568a4534a478c1ee1a"


  def install
    ENV.j1
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make", "install"
  end
end

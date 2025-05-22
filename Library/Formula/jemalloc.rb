class Jemalloc < Formula
  desc "malloc implementation emphasizing fragmentation avoidance"
  homepage "http://www.canonware.com/jemalloc/download.html"
  url "http://www.canonware.com/download/jemalloc/jemalloc-3.6.0.tar.bz2"
  sha256 "e16c2159dd3c81ca2dc3b5c9ef0d43e1f2f45b04548f42db12e7c12d7bdf84fe"
  head "https://github.com/jemalloc/jemalloc.git"
  revision 1


  def install
    system "./configure", "--disable-debug", "--prefix=#{prefix}", "--with-jemalloc-prefix="
    system "make", "install"

    # This otherwise conflicts with gperftools
    mv "#{bin}/pprof", "#{bin}/jemalloc-pprof"
  end
end

class Lzlib < Formula
  desc "Data compression library"
  homepage "http://www.nongnu.org/lzip/lzlib.html"
  url "http://download.savannah.gnu.org/releases/lzip/lzlib/lzlib-1.7.tar.gz"
  sha256 "88c919dbb16a8b5409fc8ccec31d3c604551d73e84cec8c964fd639452536214"


  def install
    system "./configure", "--prefix=#{prefix}",
                          "CC=#{ENV.cc}",
                          "CFLAGS=#{ENV.cflags}"
    system "make"
    system "make", "check"
    system "make", "install"
  end
end

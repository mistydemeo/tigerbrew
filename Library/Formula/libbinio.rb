class Libbinio < Formula
  desc "Binary I/O stream class library"
  homepage "http://libbinio.sf.net"
  url "https://downloads.sourceforge.net/project/libbinio/libbinio/1.4/libbinio-1.4.tar.bz2"
  sha256 "4a32d3154517510a3fe4f2dc95e378dcc818a4a921fc0cb992bdc0d416a77e75"


  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

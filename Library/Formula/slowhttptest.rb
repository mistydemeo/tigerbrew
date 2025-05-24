class Slowhttptest < Formula
  desc "Simulates application layer denial of service attacks"
  homepage "https://code.google.com/p/slowhttptest/"
  url "https://slowhttptest.googlecode.com/files/slowhttptest-1.6.tar.gz"
  sha256 "77c54a64cfa5f12a84729833d9b98d5f27f828f51a5e42ad5914482d0b2bd0d6"
  revision 1


  depends_on "openssl"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/slowhttptest", *%w[-u http://google.com -p 1 -r 1 -l 1 -i 1]
  end
end

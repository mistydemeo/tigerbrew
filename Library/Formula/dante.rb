class Dante < Formula
  desc "SOCKS server and client, implementing RFC 1928 and related standards"
  homepage "http://www.inet.no/dante/"
  url "http://www.inet.no/dante/files/dante-1.4.1.tar.gz"
  mirror "ftp://ftp.inet.no/pub/socks/dante-1.4.1.tar.gz"
  sha256 "b6d232bd6fefc87d14bf97e447e4fcdeef4b28b16b048d804b50b48f261c4f53"

  depends_on "miniupnpc" => :optional


  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}/dante"
    system "make", "install"
  end

  test do
    system "#{sbin}/sockd", "-v"
  end
end

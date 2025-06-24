class Libfreefare < Formula
  desc "API for MIFARE card manipulations"
  homepage "https://code.google.com/p/libfreefare/"
  url "https://libfreefare.googlecode.com/files/libfreefare-0.4.0.tar.bz2"
  sha256 "bfa31d14a99a1247f5ed49195d6373de512e3eb75bf1627658b40cf7f876bc64"
  revision 1


  depends_on "pkg-config" => :build
  depends_on "libnfc"
  depends_on "openssl"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

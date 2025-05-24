class Liboauth < Formula
  desc "C library for the OAuth Core RFC 5849 standard"
  homepage "http://liboauth.sourceforge.net"
  url "https://downloads.sourceforge.net/project/liboauth/liboauth-1.0.3.tar.gz"
  sha256 "0df60157b052f0e774ade8a8bac59d6e8d4b464058cc55f9208d72e41156811f"
  revision 1


  depends_on "openssl"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-curl"
    system "make", "install"
  end
end

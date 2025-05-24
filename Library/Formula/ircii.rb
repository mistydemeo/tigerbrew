class Ircii < Formula
  desc "IRC and ICB client"
  homepage "http://www.eterna.com.au/ircii/"
  url "http://ircii.warped.com/ircii-20150903.tar.bz2"
  sha256 "617502e17788d619510f3f5efc1217e6c9d3a55e8227ece591c56981b0901324"


  depends_on "openssl"

  def install
    ENV.append "LIBS", "-liconv"
    system "./configure", "--prefix=#{prefix}",
                          "--with-default-server=irc.freenode.net",
                          "--enable-ipv6"
    system "make"
    ENV.deparallelize
    system "make", "install"
  end
end

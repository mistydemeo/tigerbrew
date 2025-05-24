class Sipp < Formula
  desc "Traffic generator for the SIP protocol"
  homepage "http://sipp.sourceforge.net/"
  url "https://github.com/SIPp/sipp/archive/v3.4.1.tar.gz"
  sha256 "bb6829a1f3af8d8b5f08ffcd7de40e2692b4dfb9a83eccec3653a51f77a82bc4"
  revision 1


  depends_on "openssl" => :optional

  def install
    args = ["--with-pcap"]
    args << "--with-openssl" if build.with? "openssl"
    system "./configure", *args
    system "make", "DESTDIR=#{prefix}"
    bin.install "sipp"
  end
end

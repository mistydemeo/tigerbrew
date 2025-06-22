class Gsoap < Formula
  desc "SOAP stub and skeleton compiler for C and C++"
  homepage "https://gsoap2.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/gsoap2/gSOAP/gsoap_2.8.18.zip"
  sha256 "764281a67020b7b7b982ddf8e7fdffae27f7a3e61af9ab4ec8a4705a67ba7ced"

  def install
    ENV.deparallelize
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/soapcpp2", "-v"
  end
end

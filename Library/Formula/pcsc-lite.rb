class PcscLite < Formula
  desc "Middleware to access a smart card using SCard API"
  homepage "https://pcsclite.apdu.fr"
  url "https://pcsclite.apdu.fr/files/pcsc-lite-1.8.14.tar.bz2"
  sha256 "b91f97806042315a41f005e69529cb968621f73f2ddfbd1380111a175b02334e"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system sbin/"pcscd", "--version"
  end
end

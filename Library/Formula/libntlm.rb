class Libntlm < Formula
  desc "Implements Microsoft's NTLM authentication"
  homepage "http://www.nongnu.org/libntlm/"
  url "http://www.nongnu.org/libntlm/releases/libntlm-1.4.tar.gz"
  sha256 "8415d75e31d3135dc7062787eaf4119b984d50f86f0d004b964cdc18a3182589"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

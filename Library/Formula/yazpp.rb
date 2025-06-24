class Yazpp < Formula
  desc "C++ API for the Yaz toolkit"
  homepage "http://www.indexdata.com/yazpp"
  url "http://ftp.indexdata.dk/pub/yazpp/yazpp-1.6.2.tar.gz"
  sha256 "66943e4260664f9832ac654288459d447d241f1c26cab24902944e8b15c49878"


  depends_on "yaz"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

class Cln < Formula
  desc "CLN: Class Library for Numbers"
  homepage "http://www.ginac.de/CLN/"
  url "http://www.ginac.de/CLN/cln-1.3.4.tar.bz2"
  sha256 "2d99d7c433fb60db1e28299298a98354339bdc120d31bb9a862cafc5210ab748"


  depends_on "gmp"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking"
    system "make", "install"
  end
end

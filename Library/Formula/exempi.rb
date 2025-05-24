class Exempi < Formula
  desc "Library to parse XMP metadata"
  homepage "http://libopenraw.freedesktop.org/wiki/Exempi"
  url "http://libopenraw.freedesktop.org/download/exempi-2.2.2.tar.bz2"
  sha256 "0e7ad0e5e61b6828e38d31a8cc59c26c9adeed7edf4b26708c400beb6a686c07"


  depends_on "boost"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-boost=#{HOMEBREW_PREFIX}"
    system "make", "install"
  end
end

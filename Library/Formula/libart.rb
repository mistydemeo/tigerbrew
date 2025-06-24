class Libart < Formula
  desc "Library for high-performance 2D graphics"
  homepage "http://freshmeat.net/projects/libart/"
  url "https://download.gnome.org/sources/libart_lgpl/2.3/libart_lgpl-2.3.20.tar.bz2"
  sha256 "d5531ae3a206a9b5cc74e9a20d89d61b2ba3ba03d342d6a2ed48d2130ad3d847"


  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

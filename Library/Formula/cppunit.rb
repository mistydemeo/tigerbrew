class Cppunit < Formula
  desc "Unit testing framework for C++"
  homepage "https://wiki.freedesktop.org/www/Software/cppunit/"
  url "http://dev-www.libreoffice.org/src/cppunit-1.13.2.tar.gz"
  sha256 "3f47d246e3346f2ba4d7c9e882db3ad9ebd3fcbd2e8b732f946e0e3eeb9f429f"


  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end

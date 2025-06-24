class Libmodbus < Formula
  desc "Portable modbus library"
  homepage "http://libmodbus.org"
  url "http://libmodbus.org/site_media/build/libmodbus-3.1.1.tar.gz"
  sha256 "76d93aff749d6029f81dcf1fb3fd6abe10c9b48d376f3a03a4f41c5197c95c99"


  head do
    url "https://github.com/stephane/libmodbus.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end

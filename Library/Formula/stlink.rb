class Stlink < Formula
  desc "stm32 discovery line Linux programmer"
  homepage "https://github.com/texane/stlink"
  url "https://github.com/texane/stlink/archive/1.1.0.tar.gz"
  sha256 "3ac4dfcf1da0da40a1b71a8789ff0f1e7d978ea0222158bebd2de916c550682c"


  depends_on "libusb"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "st-util", "-h"
  end
end

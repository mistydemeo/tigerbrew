class Avrdude < Formula
  desc "Atmel AVR MCU programmer"
  homepage "http://savannah.nongnu.org/projects/avrdude/"
  url "http://download.savannah.gnu.org/releases/avrdude/avrdude-7.0.tar.gz"
  mirror "http://download-mirror.savannah.gnu.org/releases/avrdude/avrdude-7.0.tar.gz"
  sha256 "c0ef65d98d6040ca0b4f2b700d51463c2a1f94665441f39d15d97442dbb79b54"

  bottle do
  end

  # Need a compiler with C11 support 
  fails_with :gcc
  fails_with :gcc_4_0

  depends_on "libusb"
  depends_on "libftdi"
  depends_on "libelf"
  depends_on "libhid" => :optional

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

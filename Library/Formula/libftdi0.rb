class Libftdi0 < Formula
  desc "Library to talk to FTDI chips"
  homepage "http://www.intra2net.com/en/developer/libftdi"
  url "http://www.intra2net.com/en/developer/libftdi/download/libftdi-0.20.tar.gz"
  sha256 "3176d5b5986438f33f5208e690a8bfe90941be501cc0a72118ce3d338d4b838e"


  depends_on "libusb-compat"

  def install
    mkdir "libftdi-build" do
      system "../configure", "--prefix=#{prefix}"
      system "make"
      system "make", "install"
    end
  end
end

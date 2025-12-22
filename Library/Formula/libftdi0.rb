class Libftdi0 < Formula
  desc "Library to talk to FTDI chips"
  homepage "http://www.intra2net.com/en/developer/libftdi"
  url "http://www.intra2net.com/en/developer/libftdi/download/libftdi-0.20.tar.gz"
  sha256 "3176d5b5986438f33f5208e690a8bfe90941be501cc0a72118ce3d338d4b838e"

  bottle do
    cellar :any
    sha256 "a88a331b81f1092447daf85e85ab16da6b1cc3c271c42c05e64a1828693f9ec8" => :tiger_g3
  end

  depends_on "libusb-compat"

  def install
    mkdir "libftdi-build" do
      system "../configure", "--prefix=#{prefix}"
      system "make"
      system "make", "install"
    end
  end
end

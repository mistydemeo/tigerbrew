class DfuProgrammer < Formula
  desc "Device firmware update based USB programmer for Atmel chips"
  homepage "http://dfu-programmer.github.io"
  url "https://github.com/dfu-programmer/dfu-programmer/releases/download/v1.1.0/dfu-programmer-1.1.0.tar.gz"
  sha256 "844e469be559657bc52c9d9d03c30846acd11ffbb1ddd42438fa8af1d2b8587d"

  bottle do
    cellar :any
    sha256 "e29b8ba67e4ef02ccd429d3b949fb3d8306d3fe7491c83d3cda0c16be77aaba6" => :tiger_altivec
    sha256 "6900c46077487f2b73b9fcc55bf3c11a393e1dc6e2d74e1158afa5165ddb16ac" => :tiger_g3
  end

  head do
    url "https://github.com/dfu-programmer/dfu-programmer.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  depends_on "libusb"

  def install
    system "./bootstrap.sh" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--disable-libusb_1_0"
    system "make", "install"
  end

  test do
    system bin/"dfu-programmer", "--targets"
  end
end

class Libftdi < Formula
  desc "Library to talk to FTDI chips"
  homepage "http://www.intra2net.com/en/developer/libftdi"
  url "http://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.1.tar.bz2"
  sha256 "c0b1af1a13e2c6682a1d8041e5b164a1e0d90267cd378bb51e059bd62f821e21"

  bottle do
    cellar :any
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libusb"
  depends_on "boost" => :optional

  def install
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    mkdir "libftdi-build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end
end

class Libuvc < Formula
  desc "Cross-platform library for USB video devices"
  homepage "https://github.com/ktossell/libuvc"
  url "https://github.com/ktossell/libuvc/archive/v0.0.5.tar.gz"
  sha256 "62652a4dd024e366f41042c281e5a3359a09f33760eb1af660f950ab9e70f1f7"
  revision 1

  head "https://github.com/ktossell/libuvc.git"


  depends_on "cmake" => :build
  depends_on "libusb"
  depends_on "jpeg" => :optional

  def install
    system "cmake", ".", *std_cmake_args
    system "make"
    system "make", "install"
  end
end

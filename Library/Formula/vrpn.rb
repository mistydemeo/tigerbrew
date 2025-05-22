require "formula"

class Vrpn < Formula
  desc "Virtual reality peripheral network"
  homepage "http://vrpn.org"
  url "https://github.com/vrpn/vrpn/releases/download/v07.33/vrpn_07_33.zip"
  sha256 "3cb9e71f17eb756fbcf738e6d5084d47b3b122b68b66d42d6769105cb18a79be"

  head "git://git.cs.unc.edu/vrpn.git"


  option "clients", "Build client apps and tests"
  option "with-docs", "Build doxygen-based API documentation"
  deprecated_option "docs" => "with-docs"

  depends_on "cmake" => :build
  depends_on "libusb" # for HID support
  depends_on "doxygen" => :build if build.with? "docs"

  def install
    ENV.libstdcxx

    args = std_cmake_args

    if build.include? "clients"
      args << "-DVRPN_BUILD_CLIENTS:BOOL=ON"
    else
      args << "-DVRPN_BUILD_CLIENTS:BOOL=OFF"
    end
    args << ".."

    mkdir "build" do
      system "cmake", *args
      system "make doc" if build.with? "docs"
      system "make install"
    end
  end
end

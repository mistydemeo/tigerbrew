class Openfpgaloader < Formula
  desc "Universal utility for programming FPGA"
  homepage "https://github.com/trabucayre/openFPGALoader"
  url "https://github.com/trabucayre/openFPGALoader/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "a463690358d2510919472c2f460039a304d016a08a45970821e667eea1c48cc8"
  license "Apache-2.0"
  head "https://github.com/trabucayre/openFPGALoader.git", branch: "master"

  bottle do
  end

  needs :cxx11

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "zlib"

  def install
    mkdir "build" do
      system "cmake", "-S", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    version_output = shell_output("#{bin}/openFPGALoader -V 2>&1")
    assert_match "openFPGALoader v#{version}", version_output
  end
end

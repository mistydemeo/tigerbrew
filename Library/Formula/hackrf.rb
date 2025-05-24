class Hackrf < Formula
  desc "Low cost software radio platform"
  homepage "https://github.com/mossmann/hackrf"
  url "https://github.com/mossmann/hackrf/archive/v2015.07.2.tar.gz"
  sha256 "00eaca20eceb3f2ed4c23c80353b20dac3a29458b8d33654ff287699d2ed8877"


  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libusb"

  def install
    cd "host" do
      system "cmake", ".", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    shell_output("hackrf_transfer", 1)
  end
end

class Davix < Formula
  desc "Library and tools for advanced file I/O with HTTP-based protocols"
  homepage "https://dmc.web.cern.ch/projects/davix/home"
  url "https://github.com/cern-it-sdc-id/davix.git",
    :revision => "c53eb1472537da1694a5adc4c8fef5611eae7ab8",
    :tag => "R_0_5_0"
  version "0.5.0"

  head "https://github.com/cern-it-sdc-id/davix.git"


  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "openssl"

  def install
    ENV.libcxx

    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "#{bin}/davix-get", "http://www.google.com"
  end
end

class Xrootd < Formula
  desc "High performance, scalable, fault-tolerant access to data"
  homepage "http://xrootd.org"
  url "http://xrootd.org/download/v4.1.1/xrootd-4.1.1.tar.gz"
  sha256 "3e472ec8068adc76f10df8a1bb1c795bb37a0a9936d4a255cc62073eb86c70c4"
  head "https://github.com/xrootd/xrootd.git"


  depends_on "cmake" => :build
  depends_on "openssl"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
    share.install prefix/"man"
  end

  test do
    system "#{bin}/xrootd", "-H"
  end
end

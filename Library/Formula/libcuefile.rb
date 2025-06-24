class Libcuefile < Formula
  desc "Library to work with CUE files"
  homepage "http://www.musepack.net/"
  url "http://files.musepack.net/source/libcuefile_r475.tar.gz"
  sha256 "b681ca6772b3f64010d24de57361faecf426ee6182f5969fcf29b3f649133fe7"
  version "r475"


  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
    include.install "include/cuetools/"
  end
end

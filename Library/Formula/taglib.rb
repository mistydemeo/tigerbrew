class Taglib < Formula
  desc "Audio metadata library"
  homepage "https://taglib.github.io/"
  url "https://github.com/taglib/taglib/archive/v1.9.1.tar.gz"
  sha256 "d4da9aaaddf590ff15273b9b2c4622b6ce8377de0f40bab40155d471ede9c585"

  head "https://github.com/taglib/taglib.git"


  depends_on "cmake" => :build

  option :cxx11

  def install
    ENV.cxx11 if build.cxx11?
    ENV.append "CXXFLAGS", "-DNDEBUG=1"
    system "cmake", "-DWITH_MP4=ON", "-DWITH_ASF=ON", *std_cmake_args
    system "make"
    system "make", "install"
  end
end

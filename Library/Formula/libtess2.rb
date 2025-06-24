class Libtess2 < Formula
  desc "Refactored version of GLU tesselator"
  homepage "https://code.google.com/p/libtess2/"
  url "https://libtess2.googlecode.com/files/libtess2-1.0.zip"
  sha256 "1938805e1859cbc4459797920743def39fd04154fe60da2ee3ee2198143b96bb"


  depends_on "cmake" => :build

  def install
    # creating CMakeLists.txt, since the original source doesn't have one
    (buildpath/"CMakeLists.txt").write <<-EOS.undent
      cmake_minimum_required(VERSION 2.6)
      project(libtess)
      file(GLOB SRCS "Source/*.cpp" "Source/*.c" "Source/*.h" "Source/*.hpp")
      include_directories("Include")
      add_library(tess2 ${SRCS} ${SRCS_INCL})
    EOS

    system "cmake", ".", *std_cmake_args
    system "make"
    lib.install "libtess2.a"
    include.install "Include/tesselator.h"
  end
end

class BoostBuild < Formula
  desc "C++ build system"
  homepage "http://boost.org/boost-build2/"
  url "https://github.com/boostorg/build/archive/2014.10.tar.gz"
  sha256 "d143297d61e7c628fc40c6117d0df41cb40b33845376c331d7574f9a79b72b9f"

  head "https://github.com/boostorg/build.git"


  def install
    system "./bootstrap.sh"
    system "./b2", "--prefix=#{prefix}", "install"
  end
end

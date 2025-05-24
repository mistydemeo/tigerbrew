class Libvidstab < Formula
  desc "Transcode video stabilization plugin"
  homepage "http://public.hronopik.de/vid.stab/"
  url "https://github.com/georgmartius/vid.stab/archive/release-0.98b.tar.gz"
  sha256 "530f0bf7479ec89d9326af3a286a15d7d6a90fcafbb641e3b8bdb8d05637d025"


  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end

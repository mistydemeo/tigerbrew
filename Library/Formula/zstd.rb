class Zstd < Formula
  desc "Zstd"
  homepage "https://www.zstd.net"
  url "https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz"
  sha256 "eb33e51f49a15e023950cd7825ca74a4a2b43db8354825ac24fc1b7ee09e6fa3"
  license all_of: [
    { any_of: ["BSD-3-Clause", "GPL-2.0-only"] },
    "BSD-2-Clause", # programs/zstdgrep, lib/libzstd.pc.in
    "MIT", # lib/dictBuilder/divsufsort.c
  ]

  depends_on "make" => :build
  depends_on "gcc" => :build # only tested with gcc-14, doesn't build with gcc4

  def install
    system "gmake", "clean"
    system "gmake", "CC=gcc-14", "CXX=g++-14", "BACKTRACE=0"
    system "gmake", "install", "PREFIX=#{prefix}"
  end
end

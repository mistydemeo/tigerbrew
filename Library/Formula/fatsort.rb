class Fatsort < Formula
  desc "Sorts FAT16 and FAT32 partitions"
  homepage "http://fatsort.sourceforge.net/"
  url "https://mirrors.aliyun.com/macports/distfiles/fatsort/fatsort-1.5.0.456.tar.xz"
  sha256 "a835b47814fd30d5bad464b839e9fc404bc1a6f5a5b1f6ed760ce9744915de95"

  bottle do
    cellar :any_skip_relocation
    sha256 "319dd6f027fa9d97dddd49f6434e2d88294147b8f6f6c215220c521097db2a53" => :tiger_altivec
  end

  depends_on "help2man"

  def install
    system "make", "CC=#{ENV.cc}", "LD=#{ENV.cc}"
    bin.install "src/fatsort"
    man1.install "man/fatsort.1"
  end
end

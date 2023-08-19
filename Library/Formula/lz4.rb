class Lz4 < Formula
  desc "Lossless compression algorithm"
  homepage "https://lz4.github.io/lz4"
  url "https://github.com/lz4/lz4/archive/refs/tags/v1.9.3.tar.gz"
  version "r193"
  sha256 "030644df4611007ff7dc962d981f390361e6c97a34e5cbc393ddfbe019ffe2c1"
  head "https://github.com/lz4/lz4.git"

  bottle do
    cellar :any
    sha256 "cc8e425ec43dc5dd3132af0d9138f75510c2e15c612dff8d6276f8e701e44c66" => :el_capitan
    sha256 "246808b1662baa862812fb15923f997e40329bcb0c0ebd4595af5eb90d9c5ff9" => :yosemite
    sha256 "c38d6b8d0d0c65580e422b3baa3f19cb051e9c02f05ee02ea1fbb5721959a764" => :mavericks
    sha256 "549d8bdae519e3315ecfab95ffd3a657d6991f72571c9720dc7d976d7445bd24" => :mountain_lion
  end

  # -dynamiclib needs to be stated for a shared object to be generated.
  # https://github.com/lz4/lz4/pull/1220/files
  patch do
    url "https://patch-diff.githubusercontent.com/raw/lz4/lz4/pull/1220.patch"
    sha256 "bf3ebdfef8a0f1fd4e3e1f9892e3b04373f48d5510146dd4b6cd7b655bb4d968"
  end

  def install
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    input = "testing compression and decompression"
    input_file = testpath/"in"
    input_file.write input
    output_file = testpath/"out"
    system "sh", "-c", "cat #{input_file} | #{bin}/lz4 | #{bin}/lz4 -d > #{output_file}"
    assert_equal output_file.read, input
  end
end

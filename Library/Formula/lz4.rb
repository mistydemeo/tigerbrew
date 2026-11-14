class Lz4 < Formula
  desc "Lossless compression algorithm"
  homepage "https://lz4.github.io/lz4"
  url "https://github.com/lz4/lz4/archive/refs/tags/v1.11.1.tar.gz"
  sha256 "683fed08a844ad012196381e40badf80c0bbe4962959761416d41c9e67d77ec7"
  head "https://github.com/lz4/lz4.git"

  bottle do
    cellar :any
  end

  depends_on "make" => :build

  def install
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    system "gmake", "install", "PREFIX=#{prefix}"
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

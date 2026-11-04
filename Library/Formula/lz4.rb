class Lz4 < Formula
  desc "Lossless compression algorithm"
  homepage "https://lz4.github.io/lz4"
  url "https://github.com/lz4/lz4/archive/refs/tags/v1.11.0.tar.gz"
  sha256 "247e5fa64da5f7b75ee3dd3bed484076396c9ebe8254d9ccf693eb62800c5e26"
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

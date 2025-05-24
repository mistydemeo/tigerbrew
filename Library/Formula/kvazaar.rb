class Kvazaar < Formula
  desc "HEVC encoder"
  homepage "https://github.com/ultravideo/kvazaar"
  url "https://github.com/ultravideo/kvazaar/archive/v0.5.0.tar.gz"
  sha256 "2facdbffcf739171127487cd7d1e48c925560f39755a16542c4a40e65e293070"


  depends_on "yasm" => :build

  def install
    system "make", "-C", "src"
    bin.install "src/kvazaar"
  end

  test do
    assert_match "HEVC Encoder", shell_output("#{bin}/kvazaar 2>&1", 1)
  end
end

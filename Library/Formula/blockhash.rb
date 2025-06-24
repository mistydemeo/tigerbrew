class Blockhash < Formula
  desc "Perceptual image hash calculation tool"
  homepage "http://blockhash.io/"
  head "https://github.com/commonsmachinery/blockhash.git"
  url "https://github.com/commonsmachinery/blockhash/archive/0.1.tar.gz"
  sha256 "aef300f39be2cbc1b508af15d7ddb5b851b671b27680d8b7ab1d043cc0369893"


  depends_on "pkg-config" => :build
  depends_on "imagemagick"

  resource "testdata" do
    url "https://raw.githubusercontent.com/commonsmachinery/blockhash/ce08b465b658c4e886d49ec33361cee767f86db6/testdata/clipper_ship.jpg"
    sha256 "a9f6858876adadc83c8551b664632a9cf669c2aea4fec0c09d81171cc3b8a97f"
  end

  def install
    system "./waf", "configure", "--prefix=#{prefix}"
    system "./waf"
    system "./waf", "install"
  end

  test do
    resource("testdata").stage testpath
    hash = "00007ffe7ffe7ffe7ffe7ffe7ffe77fe77fe600e7f5e00000000000000000000"
    # Exit status is not meaningful, so use pipe_output instead of shell_output
    # for now
    # https://github.com/commonsmachinery/blockhash/pull/9
    result = pipe_output("#{bin}/blockhash #{testpath}/clipper_ship.jpg", nil, nil)
    assert result.include? hash
  end
end

# Upstream project has requested we use a mirror as the main URL
# https://github.com/Homebrew/homebrew/pull/21419
class Xz < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "http://tukaani.org/xz/"
  url "https://downloads.sourceforge.net/project/lzmautils/xz-5.8.1.tar.gz"
  mirror "https://github.com/tukaani-project/xz/releases/download/v5.8.1/xz-5.8.1.tar.gz"
  sha256 "507825b599356c10dca1cd720c9d0d0c9d5400b9de300af00e4d1ea150795543"
  license all_of: [
    "0BSD",
    "GPL-2.0-or-later",
  ]

  bottle do
    sha256 "ad6afb1a7fe157b8367fb38b6a3499758ed8e586bc8d49d971f942657548ca9f" => :tiger_altivec
    sha256 "f2dced096c310da5b0dfb22028a1bdb8a3fe620793e005725e7f454bc7e71fdf" => :tiger_g3
  end

  option :universal
  option "with-tests", "Build and run the test suite"

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  test do
    path = testpath/"data.txt"
    original_contents = "." * 1000
    path.write original_contents

    # compress: data.txt -> data.txt.xz
    system bin/"xz", path
    assert !path.exist?

    # decompress: data.txt.xz -> data.txt
    system bin/"xz", "-d", "#{path}.xz"
    assert_equal original_contents, path.read
  end
end

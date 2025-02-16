# Upstream project has requested we use a mirror as the main URL
# https://github.com/Homebrew/homebrew/pull/21419
class Xz < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "http://tukaani.org/xz/"
  url "https://downloads.sourceforge.net/project/lzmautils/xz-5.6.4.tar.gz"
  mirror "https://github.com/tukaani-project/xz/releases/download/v5.6.4/xz-5.6.4.tar.gz"
  sha256 "269e3f2e512cbd3314849982014dc199a7b2148cf5c91cedc6db629acdf5e09b"
  license all_of: [
    "0BSD",
    "GPL-2.0-or-later",
  ]

  bottle do
    sha256 "760804cf395a40ecba005e5dafb3861824490b1be57248d44f14cc66f5cd57ee" => :tiger_altivec
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
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

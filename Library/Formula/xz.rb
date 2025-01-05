# Upstream project has requested we use a mirror as the main URL
# https://github.com/Homebrew/homebrew/pull/21419
class Xz < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "http://tukaani.org/xz/"
  url "https://fossies.org/linux/misc/xz-5.4.7.tar.gz"
  mirror "https://github.com/tukaani-project/xz/releases/download/v5.6.2/xz-5.6.2.tar.gz"
  sha256 "8db6664c48ca07908b92baedcfe7f3ba23f49ef2476864518ab5db6723836e71"

  bottle do
    sha256 "adbf7a74ab4205a88c3950514c1c9deb793a109a24a0ce1a0e6b8180a54cb338" => :tiger_altivec
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

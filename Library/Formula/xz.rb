# Upstream project has requested we use a mirror as the main URL
# https://github.com/Homebrew/homebrew/pull/21419
class Xz < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "http://tukaani.org/xz/"
  # url "https://fossies.org/linux/misc/xz-5.4.4.tar.gz"
  # mirror "http://tukaani.org/xz/xz-5.4.4.tar.gz"
  url "https://www.geeklan.co.uk/files/tmp/xz-5.4.4.tar.gz"
  sha256 "aae39544e254cfd27e942d35a048d592959bd7a79f9a624afb0498bb5613bdf8"

  bottle do
    sha256 "27d90bf43274860a39b46d1f589e6386fd5a74e408d0c7c77c89c14bb54adcc7" => :tiger_altivec
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

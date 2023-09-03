# Upstream project has requested we use a mirror as the main URL
# https://github.com/Homebrew/homebrew/pull/21419
class Xz < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "http://tukaani.org/xz/"
  url "https://fossies.org/linux/misc/xz-5.4.3.tar.gz"
  mirror "http://tukaani.org/xz/xz-5.4.3.tar.gz"
  sha256 "1c382e0bc2e4e0af58398a903dd62fff7e510171d2de47a1ebe06d1528e9b7e9"

  bottle do
    sha256 "018b13f9969e2254597fed8f2d61495535d340e921e18a522fb3466a1165e2c0" => :tiger_altivec
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

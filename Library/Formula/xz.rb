# Upstream project has requested we use a mirror as the main URL
# https://github.com/Homebrew/homebrew/pull/21419
class Xz < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "http://tukaani.org/xz/"
  url "http://download.openpkg.org/components/cache/xz/xz-5.2.1.tar.gz"
  mirror "http://tukaani.org/xz/xz-5.2.1.tar.gz"
  sha256 "b918b6648076e74f8d7ae19db5ee663df800049e187259faf5eb997a7b974681"

  bottle do
    cellar :any
    sha256 "c0aca51bad86142aca2722c5155d8a733d5de4dbb0af48864029f94ab6e81a35" => :tiger_altivec
    sha1 "6b44665805221675b1adb2ac2246a8238779e6af" => :leopard_g3
    sha1 "f84ebc041d0ad358a099bdc93ed101c2cf0469cc" => :leopard_altivec
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

class Ykpers < Formula
  desc "YubiKey personalization library and tool"
  homepage "https://yubico.github.io/yubikey-personalization/"
  url "https://developers.yubico.com/yubikey-personalization/Releases/ykpers-1.17.1.tar.gz"
  sha256 "556baec2bbc94bae01293e64dc3873d68f880119ea5c3772737e4f3dc44f69c4"


  option :universal

  depends_on "pkg-config" => :build
  depends_on "libyubikey"
  depends_on "json-c" => :recommended

  def install
    ENV.universal_binary if build.universal?
    libyubikey_prefix = Formula["libyubikey"].opt_prefix
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-libyubikey-prefix=#{libyubikey_prefix}",
                          "--with-backend=osx"
    system "make", "check"
    system "make", "install"
  end

  test do
    system "#{bin}/ykinfo", "-V"
  end
end

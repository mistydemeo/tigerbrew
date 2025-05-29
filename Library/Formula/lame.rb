class Lame < Formula
  desc "Lame Aint an MP3 Encoder (LAME)"
  homepage "http://lame.sourceforge.net/"
  url "https://downloads.sourceforge.net/sourceforge/lame/lame-3.99.5.tar.gz"
  sha256 "24346b4158e4af3bd9f2e194bb23eb473c75fb7377011523353196b19b9a23ff"

  bottle do
    cellar :any
    sha1 "ac89c99c2024cd109cd7aaa1d1edc9424715ac88" => :leopard_g3
    sha1 "975485f851402e9f57ae26fe61115a9d295c02fb" => :leopard_altivec
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-debug",
                          "--prefix=#{prefix}",
                          "--enable-nasm"
    system "make", "install"
  end

  test do
    system "#{bin}/lame", "--genre-list", test_fixtures("test.mp3")
  end
end

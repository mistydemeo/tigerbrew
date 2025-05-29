class Lame < Formula
  desc "Lame Aint an MP3 Encoder (LAME)"
  homepage "http://lame.sourceforge.net/"
  url "https://downloads.sourceforge.net/sourceforge/lame/lame-3.99.5.tar.gz"
  sha256 "24346b4158e4af3bd9f2e194bb23eb473c75fb7377011523353196b19b9a23ff"

  bottle do
    cellar :any
    sha256 "c792746e24c1585b7e03f58c21d42cbe7d581cad314dbc91e48b59a6b4841d92" => :leopard_g3
    sha256 "9b704aef2371963a8941329c67c46a59cf8ed506e2af6f1380721a020d76edce" => :leopard_altivec
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

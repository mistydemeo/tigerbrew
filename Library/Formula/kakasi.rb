class Kakasi < Formula
  desc "Convert Kanji characters to Hiragana, Katakana, or Romaji"
  homepage "http://kakasi.namazu.org/"
  url "http://kakasi.namazu.org/stable/kakasi-2.3.6.tar.gz"
  sha256 "004276fd5619c003f514822d82d14ae83cd45fb9338e0cb56a44974b44961893"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    hiragana = "\xa4\xa2 \xa4\xab \xa4\xb5"
    romanji = pipe_output("kakasi -rh -ieuc -Ha", hiragana).chomp
    assert_equal "a ka sa", romanji
  end
end

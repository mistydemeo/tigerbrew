class Libass < Formula
  desc "Subtitle renderer for the ASS/SSA subtitle format"
  homepage "https://github.com/libass/libass"
  url "https://github.com/libass/libass/releases/download/0.12.3/libass-0.12.3.tar.gz"
  sha256 "5aa6b02b00de7aa2d795e8afa77def47485fcc68a190f4326b6e4d40aee30560"


  depends_on "pkg-config" => :build
  depends_on "yasm" => :build

  depends_on "freetype"
  depends_on "fribidi"
  depends_on "fontconfig"
  depends_on "harfbuzz" => :optional

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end

class Libwmf < Formula
  desc "Library for converting WMF (Window Metafile Format) files"
  homepage "http://wvware.sourceforge.net/libwmf.html"
  url "https://downloads.sourceforge.net/project/wvware/libwmf/0.2.8.4/libwmf-0.2.8.4.tar.gz"
  sha256 "5b345c69220545d003ad52bfd035d5d6f4f075e65204114a9e875e84895a7cf8"
  revision 2


  depends_on "pkg-config" => :build
  depends_on "gd"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "jpeg"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-png=#{Formula["libpng"].opt_prefix}",
                          "--with-freetype=#{Formula["freetype"].opt_prefix}"
    system "make"
    ENV.j1 # yet another rubbish Makefile
    system "make", "install"
  end
end

class Writerperfect < Formula
  desc "Library for importing WordPerfect documents"
  homepage "http://sourceforge.net/p/libwpd/wiki/writerperfect/"
  url "https://downloads.sourceforge.net/project/libwpd/writerperfect/writerperfect-0.9.4/writerperfect-0.9.4.tar.xz"
  sha256 "6714bf945a657550eb84bd2f1f0b78b894f59536d8302942810134426f7a23ea"


  depends_on "pkg-config" => :build
  depends_on "boost" => :build
  depends_on "libodfgen"
  depends_on "libwps"
  depends_on "libwpg"
  depends_on "libwpd"
  depends_on "libetonyek" => :optional
  depends_on "libvisio" => :optional
  depends_on "libmspub" => :optional

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

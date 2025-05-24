class Libquvi < Formula
  desc "C library to parse flash media stream properties"
  homepage "http://quvi.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/quvi/0.4/libquvi/libquvi-0.4.1.tar.bz2"
  sha256 "f5a2fb0571634483e8a957910f44e739f5a72eb9a1900bd10b453c49b8d5f49d"
  revision 1


  depends_on "pkg-config" => :build
  depends_on "curl" if MacOS.version < :snow_leopard
  depends_on "lua"

  resource "scripts" do
    url "https://downloads.sourceforge.net/project/quvi/0.4/libquvi-scripts/libquvi-scripts-0.4.14.tar.xz"
    sha256 "b8d17d53895685031cd271cf23e33b545ad38cad1c3bddcf7784571382674c65"
  end

  def install
    scripts = prefix/"libquvi-scripts"
    resource("scripts").stage do
      system "./configure", "--prefix=#{scripts}", "--with-nsfw"
      system "make", "install"
    end
    ENV.append_path "PKG_CONFIG_PATH", "#{scripts}/lib/pkgconfig"

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end

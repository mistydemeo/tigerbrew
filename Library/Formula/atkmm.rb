class Atkmm < Formula
  desc "Official C++ interface for the ATK accessibility toolkit library"
  homepage "http://www.gtkmm.org"
  url "https://download.gnome.org/sources/atkmm/2.22/atkmm-2.22.7.tar.xz"
  sha256 "bfbf846b409b4c5eb3a52fa32a13d86936021969406b3dcafd4dd05abd70f91b"


  depends_on "pkg-config" => :build
  depends_on "atk"
  depends_on "glibmm"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end

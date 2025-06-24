class Libgda < Formula
  desc "Provides unified data access to the GNOME project"
  homepage "http://www.gnome-db.org/"
  url "https://download.gnome.org/sources/libgda/5.2/libgda-5.2.4.tar.xz"
  sha256 "2cee38dd583ccbaa5bdf6c01ca5f88cc08758b9b144938a51a478eb2684b765e"


  revision 2

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "itstool" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on "readline"
  depends_on "libgcrypt"
  depends_on "sqlite"
  depends_on "openssl"

  def install
    ENV.libxml2
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-binreloc",
                          "--disable-gtk-doc",
                          "--without-java"
    system "make"
    system "make", "install"
  end
end

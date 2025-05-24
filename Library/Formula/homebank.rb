class Homebank < Formula
  desc "Manage your personal accounts at home"
  homepage "http://homebank.free.fr"
  url "http://homebank.free.fr/public/homebank-5.0.5.tar.gz"
  sha256 "67c47709517d325fc8d601bb8552e3c8a1ad3b820a2c0a403ed20f00c795903c"


  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "gettext"
  depends_on "gtk+3"
  depends_on "gnome-icon-theme"
  depends_on "hicolor-icon-theme"
  depends_on "freetype"
  depends_on "fontconfig"
  depends_on "libofx" => :optional

  def install
    args = ["--disable-dependency-tracking",
            "--prefix=#{prefix}"]
    args << "--with-ofx" if build.with? "libofx"

    system "./configure", *args
    chmod 0755, "./install-sh"
    system "make", "install"
  end

  test do
    system "#{bin}/homebank", "--version"
  end
end

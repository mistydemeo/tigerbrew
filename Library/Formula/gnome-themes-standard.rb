class GnomeThemesStandard < Formula
  desc "Default themes for the GNOME desktop environment"
  homepage "https://gitlab.gnome.org/Archive/gnome-themes-extra"
  url "https://download.gnome.org/sources/gnome-themes-standard/3.16/gnome-themes-standard-3.16.2.tar.xz"
  sha256 "59eb79a59d44b5cd8daa8de1e7559fb5186503dcd78e47d0b72cb896d8654b9f"

  bottle do
    cellar :any
    sha256 "7336f11f7ae9aaba343fa59a6be45c75b52faae6c4345c124d853a5cfd37e3b3" => :yosemite
    sha256 "6f229fa6ef6e3b30dc5073adecd94dc3ad9974b784685e82d8506f9546ddd074" => :mavericks
    sha256 "ebcafeb59a4889d36e3828c7cb803fdee586f5912f779b6b9c74ee1289e9bdb7" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "gettext" => :build
  depends_on "gtk+"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-gtk3-engine"

    system "make", "install"
  end

  test do
    assert (share/"icons/HighContrast/scalable/actions/document-open-recent.svg").exist?
    assert (lib/"gtk-2.0/2.10.0/engines/libadwaita.so").exist?
  end
end

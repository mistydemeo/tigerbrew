class Anjuta < Formula
  desc "GNOME Integrated Development Environment"
  homepage "http://anjuta.org"
  url "https://download.gnome.org/sources/anjuta/3.18/anjuta-3.18.0.tar.xz"
  sha256 "6a3fec0963f04bc62a9dfb951e577a3276d39c3414083ef73163c3fea8e741ba"


  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "itstool" => :build
  depends_on "gtksourceview3"
  depends_on "libxml2" => "with-python"
  depends_on "libgda"
  depends_on "gdl"
  depends_on "vte3"
  depends_on "hicolor-icon-theme"
  depends_on "gnome-icon-theme"
  depends_on "gnome-themes-standard" => :optional
  depends_on "shared-mime-info"
  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "vala" => :recommended
  depends_on "autogen" => :recommended

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-schemas-compile"
    ENV.append_path "PYTHONPATH", "#{Formula["libxml2"].opt_lib}/python2.7/site-packages"
    system "make", "install"
  end

  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
    system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "-f", "-t", "#{HOMEBREW_PREFIX}/share/icons/hicolor"
    # HighContrast is provided by gnome-themes-standard
    if File.file?("#{HOMEBREW_PREFIX}/share/icons/HighContrast/.icon-theme.cache")
      system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "-f", "-t", "#{HOMEBREW_PREFIX}/share/icons/HighContrast"
    end
    system "#{Formula["shared-mime-info"].opt_bin}/update-mime-database", "#{HOMEBREW_PREFIX}/share/mime"
  end

  test do
    system "#{bin}/anjuta", "--version"
  end
end

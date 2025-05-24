class GtkDoc < Formula
  desc "GTK+ documentation tool"
  homepage "http://www.gtk.org/gtk-doc/"
  url "https://download.gnome.org/sources/gtk-doc/1.24/gtk-doc-1.24.tar.xz"
  sha256 "b420759ea05c760301bada14e428f1b321f5312f44e10a176d6804822dabb58b"


  depends_on "pkg-config" => :build
  depends_on "gnome-doc-utils" => :build
  depends_on "itstool" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on "docbook"
  depends_on "docbook-xsl"
  depends_on "libxml2" => "with-python"

  def install
    ENV.append_path "PYTHONPATH", "#{Formula["libxml2"].opt_lib}/python2.7/site-packages"

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-xml-catalog=#{etc}/xml/catalog"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/gtkdoc-scan", "--module=test"
    system "#{bin}/gtkdoc-mkdb", "--module=test"
  end
end

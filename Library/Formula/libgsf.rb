class Libgsf < Formula
  desc "I/O abstraction library for dealing with structured file formats"
  homepage "https://developer.gnome.org/gsf/"
  url "https://download.gnome.org/sources/libgsf/1.14/libgsf-1.14.34.tar.xz"
  sha256 "f0fea447e0374a73df45b498fd1701393f8e6acb39746119f8a292fb4a0cb528"


  head do
    url "https://github.com/GNOME/libgsf.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "gnome-common" => :build
    depends_on "gtk-doc" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "gdk-pixbuf" => :optional
  depends_on "gettext"
  depends_on "glib"
  depends_on "libxml2" if MacOS.version < :snow_leopard

  def install
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"
  end

  test do
    system bin/"gsf", "--help"
    (testpath/"test.c").write <<-EOS.undent
      #include <gsf/gsf-utils.h>
      int main()
      {
          void
          gsf_init (void);
          return 0;
      }
    EOS
    system ENV.cc, "-I#{include}/libgsf-1",
           "-I#{Formula["glib"].opt_include}/glib-2.0",
           "-I#{Formula["glib"].opt_lib}/glib-2.0/include",
           testpath/"test.c", "-o", testpath/"test"
    system "./test"
  end
end

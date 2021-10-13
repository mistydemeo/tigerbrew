class Cairo < Formula
  desc "Vector graphics library with cross-device output support"
  homepage "http://cairographics.org/"
  url "https://cairographics.org/releases/cairo-1.14.8.tar.xz"
  mirror "https://www.mirrorservice.org/sites/ftp.netbsd.org/pub/pkgsrc/distfiles/cairo-1.14.8.tar.xz"
  sha256 "d1f2d98ae9a4111564f6de4e013d639cf77155baf2556582295a0f00a9bc5e20"

  bottle do
    sha256 "d42bef08f00c10438064d93b3c7e317a95715c65131526b04b9dd8cc1c917b30" => :tiger_altivec
  end

  keg_only :provided_pre_mountain_lion

  option :universal

  depends_on "pkg-config" => :build
  depends_on :x11 => :recommended if MacOS.version <= :leopard
  depends_on :x11 => :optional if MacOS.version > :leopard
  depends_on "freetype"
  depends_on "fontconfig"
  depends_on "libpng"
  depends_on "pixman"
  depends_on "glib"

  # Fixes building when certain CoreText features are unavailable
  # https://github.com/mistydemeo/tigerbrew/issues/452
  if MacOS.version < :leopard
    patch do
      url "https://cgit.freedesktop.org/~ranma42/cairo/patch/?id=5a8a9c97ed268004cbac510d39739ff56c0fb43c"
      sha256 "e4d5cea0f00108bab020e669659e8c20dfcbf29f43b15aeeebd2936e45ededd0"
    end
  end

  def install
    ENV.universal_binary if build.universal?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-gobject=yes
      --enable-svg=yes
      --enable-tee=yes
      --enable-quartz-image
    ]

    if build.with? "x11"
      # Tiger's X11 does not include XCB,
      # and Leopard's X11 has an XCB that's too old.
      args << "--enable-xcb=yes" if MacOS.version > :leopard
      args << "--enable-xlib=yes" << "--enable-xlib-xrender=yes"
    else
      args << "--enable-xcb=no" << "--enable-xlib=no" << "--enable-xlib-xrender=no"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <cairo.h>

      int main(int argc, char *argv[]) {

        cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 600, 400);
        cairo_t *context = cairo_create(surface);

        return 0;
      }
    EOS
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    libpng = Formula["libpng"]
    pixman = Formula["pixman"]
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/cairo
      -I#{libpng.opt_include}/libpng16
      -I#{pixman.opt_include}/pixman-1
      -L#{lib}
      -lcairo
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end

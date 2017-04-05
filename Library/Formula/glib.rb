class Glib < Formula
  desc "Core application library for C"
  homepage "https://developer.gnome.org/glib/"
  url "https://download.gnome.org/sources/glib/2.50/glib-2.50.1.tar.xz"
  sha256 "2ef87a78f37c1eb5b95f4cc95efd5b66f69afad9c9c0899918d04659cf6df7dd"

  bottle do
    sha256 "4892a83baa553ef938ec2a7cb4d6f72af9bbd45ddef730e42b9640c5c9883fe4" => :sierra
    sha256 "818420b0efd28fc6ed8fce3be2291cb4761ba264a535b795bf42e251b432c7c2" => :el_capitan
    sha256 "cfde246fc576b0cf6c4609045b5f1dc4c412133047036326176e350e425e8e4e" => :yosemite
  end

  option :universal
  option "with-test", "Build a debug build and run tests. NOTE: Not all tests succeed yet"
  option "with-static", "Build glib with a static archive."

  deprecated_option "test" => "with-test"

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "libffi"
  depends_on "pcre"
  depends_on :python if MacOS.version < :leopard
  # the version of zlib which comes with Tiger does not
  # export some symbols glib expects
  depends_on "zlib" if MacOS.version == :tiger

  fails_with :llvm do
    build 2334
    cause "Undefined symbol errors while linking"
  end

  resource "config.h.ed" do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/eb51d82/glib/config.h.ed"
    version "111532"
    sha256 "9f1e23a084bc879880e589893c17f01a2f561e20835d6a6f08fcc1dad62388f1"
  end

  # https://bugzilla.gnome.org/show_bug.cgi?id=673135 Resolved as wontfix,
  # but needed to fix an assumption about the location of the d-bus machine
  # id file.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/patches/59e4d327791d4fe3423c2c871adb98e3f3f07633/glib/hardcoded-paths.diff"
    sha256 "a4cb96b5861672ec0750cb30ecebe1d417d38052cac12fbb8a77dbf04a886fcb"
  end

  # Fixes compilation with FSF GCC. Doesn't fix it on every platform, due
  # to unrelated issues in GCC, but improves the situation.
  # Patch submitted upstream: https://bugzilla.gnome.org/show_bug.cgi?id=672777
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/a39dec26/glib/gio.patch"
    sha256 "284cbf626f814c21f30167699e6e59dcc0d31000d71151f25862b997a8c8493d"
  end

  patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/fe50d25d/glib/universal.diff"
      sha256 "e21f902907cca543023c930101afe1d0c1a7ad351daa0678ba855341f3fd1b57"
  end if build.universal?

  # Fixes g_get_monotonic_time on non-Intel Macs; submitted upstream:
  # https://bugzilla.gnome.org/show_bug.cgi?id=728123
  patch do
    url "https://bug728123.bugzilla-attachments.gnome.org/attachment.cgi?id=275596"
    sha1 "5637d98e1c7bbfa8824e60612976a8c13d0c0fb6"
  end

  # Reverts GNotification support on macOS.
  # This only supports OS X 10.9, and the reverted commits removed the
  # ability to build glib on older versions of OS X.
  # https://bugzilla.gnome.org/show_bug.cgi?id=747146
  # Reverts upstream commits 36e093a31a9eb12021e7780b9e322c29763ffa58
  # and 89058e8a9b769ab223bc75739f5455dab18f7a3d, with equivalent changes
  # also applied to configure and gio/Makefile.in
  if MacOS.version < :mavericks
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/a4fe61b/glib/gnotification-mountain.patch"
      sha256 "5bf6d562dd2be811d71e6f84eb43fc6c51a112db49ec0346c1b30f4f6f4a4233"
    end
  end

  def install
    ENV.universal_binary if build.universal?

    inreplace %w[gio/gdbusprivate.c gio/xdgmime/xdgmime.c glib/gutils.c],
      "@@HOMEBREW_PREFIX@@", HOMEBREW_PREFIX

    # renaming is necessary for patches to work
    mv "gio/gcocoanotificationbackend.c", "gio/gcocoanotificationbackend.m" unless MacOS.version < :mavericks
    mv "gio/gnextstepsettingsbackend.c", "gio/gnextstepsettingsbackend.m"

    # Disable dtrace; see https://trac.macports.org/ticket/30413
    args = %W[
      --disable-maintainer-mode
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-dtrace
      --disable-libelf
      --prefix=#{prefix}
      --localstatedir=#{var}
      --with-gio-module-dir=#{HOMEBREW_PREFIX}/lib/gio/modules
    ]

    args << "--enable-static" if build.with? "static"

    system "./configure", *args

    if build.universal?
      buildpath.install resource("config.h.ed")
      system "ed -s - config.h <config.h.ed"
    end

    # disable creating directory for GIO_MOUDLE_DIR, we will do this manually in post_install
    inreplace "gio/Makefile", "$(mkinstalldirs) $(DESTDIR)$(GIO_MODULE_DIR)", ""

    system "make"
    # the spawn-multithreaded tests require more open files
    system "ulimit -n 1024; make check" if build.with? "test"
    system "make", "install"

    # `pkg-config --libs glib-2.0` includes -lintl, and gettext itself does not
    # have a pkgconfig file, so we add gettext lib and include paths here.
    gettext = Formula["gettext"].opt_prefix
    inreplace lib+"pkgconfig/glib-2.0.pc" do |s|
      s.gsub! "Libs: -L${libdir} -lglib-2.0 -lintl",
              "Libs: -L${libdir} -lglib-2.0 -L#{gettext}/lib -lintl"
      s.gsub! "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include",
              "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include -I#{gettext}/include"
    end

    (share+"gtk-doc").rmtree
  end

  def post_install
    (HOMEBREW_PREFIX/"lib/gio/modules").mkpath
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <string.h>
      #include <glib.h>

      int main(void)
      {
          gchar *result_1, *result_2;
          char *str = "string";

          result_1 = g_convert(str, strlen(str), "ASCII", "UTF-8", NULL, NULL, NULL);
          result_2 = g_convert(result_1, strlen(result_1), "UTF-8", "ASCII", NULL, NULL, NULL);

          return (strcmp(str, result_2) == 0) ? 0 : 1;
      }
      EOS
    flags = ["-I#{include}/glib-2.0", "-I#{lib}/glib-2.0/include", "-lglib-2.0"]
    system ENV.cc, "-o", "test", "test.c", *(flags + ENV.cflags.to_s.split)
    system "./test"
  end
end

__END__
diff --git a/gobject/gtype.h b/gobject/gtype.h
index 8a1bff2..4474ede 100644
--- a/gobject/gtype.h
+++ b/gobject/gtype.h
@@ -1580,7 +1580,7 @@ type_name##_get_type (void) \
  */
 #define G_DEFINE_BOXED_TYPE_WITH_CODE(TypeName, type_name, copy_func, free_func, _C_) _G_DEFINE_BOXED_TYPE_BEGIN (TypeName, type_name, copy_func, free_func) {_C_;} _G_DEFINE_TYPE_EXTENDED_END()

-#if !defined (__cplusplus) && (__GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7))
+#if !defined (__cplusplus) && (__GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7) && !defined (__ppc64__))
 #define _G_DEFINE_BOXED_TYPE_BEGIN(TypeName, type_name, copy_func, free_func) \
 GType \
 type_name##_get_type (void) \

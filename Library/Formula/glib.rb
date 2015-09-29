class Glib < Formula
  desc "Core application library for C"
  homepage "https://developer.gnome.org/glib/"
  url "https://download.gnome.org/sources/glib/2.46/glib-2.46.0.tar.xz"
  sha256 "b1cee83469ae7d80f17c267c37f090414e93960bd62d2b254a5a96fbc5baacb4"

  revision 1

  bottle do
    sha256 "15fd5f2f9eb1cbdb340c5d0f4fce7f0cad222c7663801f41d13ae04f075135c2" => :tiger_altivec
    sha256 "a77fa2cdde4c04eb14fba684bcbafcd1be11aad39e98431cba135eeead9eaf92" => :leopard_g3
    sha256 "92b517c29d6ccdc549dd4952d1d85c250e6dc663e36379fd053771ff01840a7a" => :leopard_altivec
  end

  option :universal
  option "with-test", "Build a debug build and run tests. NOTE: Not all tests succeed yet"
  option "with-static", "Build glib with a static archive."

  deprecated_option "test" => "with-test"

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "libffi"
  # the version of zlib which comes with Tiger does not
  # export some symbols glib expects
  depends_on 'homebrew/dupes/zlib' if MacOS.version == :tiger

  fails_with :llvm do
    build 2334
    cause "Undefined symbol errors while linking"
  end

  resource "config.h.ed" do
    url "https://svn.macports.org/repository/macports/trunk/dports/devel/glib2/files/config.h.ed", :using => :curl
    mirror "https://trac.macports.org/export/111532/trunk/dports/devel/glib2/files/config.h.ed"
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
    url "https://raw.githubusercontent.com/Homebrew/patches/59e4d327791d4fe3423c2c871adb98e3f3f07633/glib/gio.patch"
    sha256 "cc3f0f6d561d663dfcdd6154b075150f68a36f5a92f94e5163c1c20529bfdf32"
  end

  patch do
    url "https://raw.githubusercontent.com/Homebrew/patches/59e4d327791d4fe3423c2c871adb98e3f3f07633/glib/universal.patch"
    sha256 "7e1ad7667c7d89fcd08950c9c32cd66eb9c8e2ee843f023d1fadf09a9ba39fee"
  end if build.universal?

  # Fixes g_get_monotonic_time on non-Intel Macs; submitted upstream:
  # https://bugzilla.gnome.org/show_bug.cgi?id=728123
  patch do
    url "https://bug728123.bugzilla-attachments.gnome.org/attachment.cgi?id=275596"
    sha1 "5637d98e1c7bbfa8824e60612976a8c13d0c0fb6"
  end

  # Reverts GNotification support on OS X.
  # This only supports OS X 10.9, and the reverted commits removed the
  # ability to build glib on older versions of OS X.
  # https://bugzilla.gnome.org/show_bug.cgi?id=747146
  # Reverts upstream commits 36e093a31a9eb12021e7780b9e322c29763ffa58
  # and 89058e8a9b769ab223bc75739f5455dab18f7a3d, with equivalent changes
  # also applied to configure and gio/Makefile.in
  if MacOS.version < :mavericks
    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/59e4d327791d4fe3423c2c871adb98e3f3f07633/glib/gnotification-mountain.patch"
      sha256 "723def732304552ca55ae9f5b568ff3e8a59a14d512af72b6c1f0421f8228a68"
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

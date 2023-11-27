class Glib < Formula
  desc "Core application library for C"
  homepage "https://developer.gnome.org/glib/"
  url "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/glib/2.59/glib-2.59.0.tar.xz"
  sha256 "664a5dee7307384bb074955f8e5891c7cecece349bbcc8a8311890dc185b428e"

  bottle do
    sha256 "cd2cc4166c82571ca781566650e1600d351669f060ab9782c6c1107be368e65c" => :tiger_altivec
  end

  # Fixes g_get_monotonic_time on non-Intel Macs; submitted upstream:
  # https://bugzilla.gnome.org/show_bug.cgi?id=728123
  # https://bugzilla.gnome.org/show_bug.cgi?id=673135 Resolved as wontfix,
  # but needed to fix an assumption about the location of the d-bus machine
  # id file.
  patch :p0, :DATA

  option "with-test", "Build a debug build and run tests. NOTE: Not all tests succeed yet"
  option "with-static", "Build glib with a static archive."

  deprecated_option "test" => "with-test"

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "libiconv"
  depends_on "libffi"
  depends_on "pcre"
  depends_on "python3"
  depends_on "zlib"
  # glib's switched to using Meson to build
  # 2.59.0 is the last version to ship with autoconf support but we need to bootstrap
  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build

  def install
    inreplace %w[gio/gdbusprivate.c gio/xdgmime/xdgmime.c glib/gutils.c],
      "HOMEBREWPREFIX", HOMEBREW_PREFIX

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

    # autogen.sh defaults to running configure itself, without any args
    system "env NOCONFIGURE=1 ./autogen.sh"
    system "./configure", *args

    # disable creating directory for GIO_MODULE_DIR, we will do this manually in post_install
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
    flags = ["-I#{include}/glib-2.0", "-I#{lib}/glib-2.0/include", "-L#{lib}", "-lglib-2.0.0"]
    system ENV.cc, "-o", "test", "test.c", *(flags + ENV.cflags.to_s.split)
    system "./test"
  end

end
__END__
--- gio/gosxcontenttype.m.orig	2023-05-24 18:28:06.000000000 +0100
+++ gio/gosxcontenttype.m	2023-05-24 18:28:28.000000000 +0100
@@ -24,6 +24,7 @@
 #include "gthemedicon.h"
 
 #include <CoreServices/CoreServices.h>
+#include <ApplicationServices/ApplicationServices.h>
 
 #define XDG_PREFIX _gio_xdg
 #include "xdgmime/xdgmime.h"
--- glib/gmain.c.orig	2023-05-24 18:52:38.000000000 +0100
+++ glib/gmain.c	2023-05-24 18:56:15.000000000 +0100
@@ -2768,46 +2768,35 @@
 g_get_monotonic_time (void)
 {
   static mach_timebase_info_data_t timebase_info;
+  static double absolute_to_micro;
 
   if (timebase_info.denom == 0)
     {
-      /* This is a fraction that we must use to scale
-       * mach_absolute_time() by in order to reach nanoseconds.
-       *
-       * We've only ever observed this to be 1/1, but maybe it could be
-       * 1000/1 if mach time is microseconds already, or 1/1000 if
-       * picoseconds.  Try to deal nicely with that.
+      /* mach_absolute_time() returns "absolute time units", rather than
+         seconds; the mach_timebase_info_data_t struct provides a
+         fraction that can be used to convert these units into seconds.
        */
       mach_timebase_info (&timebase_info);
 
-      /* We actually want microseconds... */
-      if (timebase_info.numer % 1000 == 0)
-        timebase_info.numer /= 1000;
-      else
-        timebase_info.denom *= 1000;
-
-      /* We want to make the numer 1 to avoid having to multiply... */
-      if (timebase_info.denom % timebase_info.numer == 0)
-        {
-          timebase_info.denom /= timebase_info.numer;
-          timebase_info.numer = 1;
-        }
-      else
-        {
-          /* We could just multiply by timebase_info.numer below, but why
-           * bother for a case that may never actually exist...
-           *
-           * Plus -- performing the multiplication would risk integer
-           * overflow.  If we ever actually end up in this situation, we
-           * should more carefully evaluate the correct course of action.
-           */
-          mach_timebase_info (&timebase_info); /* Get a fresh copy for a better message */
-          g_error ("Got weird mach timebase info of %d/%d.  Please file a bug against GLib.",
-                   timebase_info.numer, timebase_info.denom);
-        }
+      absolute_to_micro = 1e-3 * timebase_info.numer / timebase_info.denom;
     }
 
-  return mach_absolute_time () / timebase_info.denom;
+  if (timebase_info.denom == 1 && timebase_info.numer == 1)
+    {
+      /* On Intel, the fraction has been 1/1 to date, so we can shortcut
+         the conversion into microseconds.
+       */
+      return mach_absolute_time () / 1000;
+    }
+  else
+    {
+      /* On ARM and PowerPC, the value is unpredictable and is hardware
+         dependent, so we can't guess. Both the units and numer/denom
+         are extremely large, so the conversion number is stored as a
+         double in order to avoid integer overflow.
+       */
+      return mach_absolute_time () * absolute_to_micro;
+    }
 }
 #else
 gint64
--- gio/gdbusprivate.c.orig	2018-12-23 13:10:41.000000000 +0000
+++ gio/gdbusprivate.c	2023-11-26 21:19:10.000000000 +0000
@@ -2098,7 +2098,7 @@
   /* TODO: use PACKAGE_LOCALSTATEDIR ? */
   ret = NULL;
   first_error = NULL;
-  if (!g_file_get_contents ("/var/lib/dbus/machine-id",
+  if (!g_file_get_contents ("HOMEBREWPREFIX/var/lib/dbus/machine-id",
                             &ret,
                             NULL,
                             &first_error) &&
@@ -2108,7 +2108,7 @@
                             NULL))
     {
       g_propagate_prefixed_error (error, first_error,
-                                  _("Unable to load /var/lib/dbus/machine-id or /etc/machine-id: "));
+                                  _("Unable to load HOMEBREWPREFIX or /etc/machine-id: "));
     }
   else
     {
--- gio/xdgmime/xdgmime.c.orig	2018-12-23 13:10:41.000000000 +0000
+++ gio/xdgmime/xdgmime.c	2023-11-26 21:19:10.000000000 +0000
@@ -235,7 +235,7 @@
   xdg_data_dirs = getenv ("XDG_DATA_DIRS");
 
   if (xdg_data_dirs == NULL)
-    xdg_data_dirs = "/usr/local/share/:/usr/share/";
+    xdg_data_dirs = "HOMEBREWPREFIX/share/:/usr/share/";
 
   /* Work out how many dirs we’re dealing with. */
   if (xdg_data_home != NULL || home != NULL)
--- glib/gutils.c.orig	2018-12-23 13:10:41.000000000 +0000
+++ glib/gutils.c	2023-11-26 21:19:10.000000000 +0000
@@ -2125,7 +2125,7 @@
    */
 #ifndef G_OS_WIN32
   if (!data_dirs || !data_dirs[0])
-    data_dirs = "/usr/local/share/:/usr/share/";
+    data_dirs = "HOMEBREWPREFIX/share/:/usr/share/";
 
   data_dir_vector = g_strsplit (data_dirs, G_SEARCHPATH_SEPARATOR_S, 0);
 #else

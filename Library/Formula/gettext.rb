class Gettext < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftpmirror.gnu.org/gettext/gettext-0.22.4.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gettext/gettext-0.22.4.tar.xz"
  sha256 "29217f1816ee2e777fa9a01f9956a14139c0c23cc1b20368f06b2888e8a34116"

  bottle do
    sha256 "c64bb31029e29599442653fe1e0f2216ae8fe144451a0541896f6e367df0018f" => :tiger_altivec
  end

  keg_only :shadowed_by_osx, "OS X provides the BSD gettext library and some software gets confused if both are in the library path."

  option :universal
  option 'with-examples', 'Keep example files'

  # Fix lang-python-* failures when a traditional French locale
  # https://git.savannah.gnu.org/gitweb/?p=gettext.git;a=patch;h=3c7e67be7d4dab9df362ab19f4f5fa3b9ca0836b
  # Skip the gnulib tests as they have their own set of problems which has nothing to do with what's being built.
  # Fix the Apple clang version cutoff point for a working __has_attribute via Macports
  # https://savannah.gnu.org/bugs/?63866
  patch :p0, :DATA

  fails_with :clang do
    build 500
    cause "___atomic_compare_exchange_n() / ___atomic_store_n() called in gnulib but not defined"
  end

  def install
    ENV.libxml2
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-included-gettext",
                          "--with-included-glib",
                          "--with-included-libcroco",
                          "--with-included-libunistring",
                          "--with-emacs",
                          "--with-lispdir=#{share}/emacs/site-lisp/gettext",
                          "--disable-java",
                          "--disable-csharp",
                          # Don't use VCS systems to create these archives
                          "--without-git",
                          "--without-cvs",
                          "--without-xz"
    system "make"
    system "make", "check"
    ENV.deparallelize # install doesn't support multiple make jobs
    system "make", "install"
  end

  test do
    system "#{bin}/gettext", "test"
  end
end
__END__
--- gettext-tools/tests/lang-python-1.orig	2023-09-18 21:10:32.000000000 +0100
+++ gettext-tools/tests/lang-python-1	2023-11-30 23:15:43.000000000 +0000
@@ -3,9 +3,10 @@
 
 # Test of gettext facilities in the Python language.
 
-# Note: This test fails with Python 2.3 ... 2.7 when an UTF-8 locale is present.
+# Note: This test fails with Python 2.3 ... 2.7 when an ISO-8859-1 locale is
+# present.
 # It looks like a bug in Python's gettext.py. This here is a quick workaround:
-UTF8_LOCALE_UNSUPPORTED=yes
+ISO8859_LOCALE_UNSUPPORTED=yes
 
 cat <<\EOF > prog1.py
 import gettext
@@ -82,16 +83,16 @@
 
 : ${LOCALE_FR=fr_FR}
 : ${LOCALE_FR_UTF8=fr_FR.UTF-8}
-if test $LOCALE_FR != none; then
-  prepare_locale_ fr $LOCALE_FR
-  LANGUAGE= LC_ALL=$LOCALE_FR python prog1.py > prog.out || Exit 1
-  ${DIFF} prog.ok prog.out || Exit 1
+if test $LOCALE_FR_UTF8 != none; then
+  prepare_locale_ fr $LOCALE_FR_UTF8
+  LANGUAGE= LC_ALL=$LOCALE_FR_UTF8 python prog1.py > prog.out || Exit 1
+  ${DIFF} prog.oku prog.out || Exit 1
 fi
-if test -z "$UTF8_LOCALE_UNSUPPORTED"; then
-  if test $LOCALE_FR_UTF8 != none; then
-    prepare_locale_ fr $LOCALE_FR_UTF8
-    LANGUAGE= LC_ALL=$LOCALE_FR_UTF8 python prog1.py > prog.out || Exit 1
-    ${DIFF} prog.oku prog.out || Exit 1
+if test -z "$ISO8859_LOCALE_UNSUPPORTED"; then
+  if test $LOCALE_FR != none; then
+    prepare_locale_ fr $LOCALE_FR
+    LANGUAGE= LC_ALL=$LOCALE_FR python prog1.py > prog.out || Exit 1
+    ${DIFF} prog.ok prog.out || Exit 1
   fi
   if test $LOCALE_FR = none && test $LOCALE_FR_UTF8 = none; then
     if test -f /usr/bin/localedef; then
@@ -102,11 +103,11 @@
     Exit 77
   fi
 else
-  if test $LOCALE_FR = none; then
+  if test $LOCALE_FR_UTF8 = none; then
     if test -f /usr/bin/localedef; then
-      echo "Skipping test: no traditional french locale is installed"
+      echo "Skipping test: no french Unicode locale is installed"
     else
-      echo "Skipping test: no traditional french locale is supported"
+      echo "Skipping test: no french Unicode locale is supported"
     fi
     Exit 77
   fi
--- gettext-tools/tests/lang-python-2.orig	2023-09-18 21:10:32.000000000 +0100
+++ gettext-tools/tests/lang-python-2	2023-11-30 23:15:43.000000000 +0000
@@ -4,9 +4,10 @@
 # Test of gettext facilities (including plural handling) in the Python
 # language.
 
-# Note: This test fails with Python 2.3 ... 2.7 when an UTF-8 locale is present.
+# Note: This test fails with Python 2.3 ... 2.7 when an ISO-8859-1 locale is
+# present.
 # It looks like a bug in Python's gettext.py. This here is a quick workaround:
-UTF8_LOCALE_UNSUPPORTED=yes
+ISO8859_LOCALE_UNSUPPORTED=yes
 
 cat <<\EOF > prog2.py
 import sys
@@ -103,16 +104,16 @@
 
 : ${LOCALE_FR=fr_FR}
 : ${LOCALE_FR_UTF8=fr_FR.UTF-8}
-if test $LOCALE_FR != none; then
-  prepare_locale_ fr $LOCALE_FR
-  LANGUAGE= LC_ALL=$LOCALE_FR python prog2.py 2 > prog.out || Exit 1
-  ${DIFF} prog.ok prog.out || Exit 1
+if test $LOCALE_FR_UTF8 != none; then
+  prepare_locale_ fr $LOCALE_FR_UTF8
+  LANGUAGE= LC_ALL=$LOCALE_FR_UTF8 python prog2.py 2 > prog.out || Exit 1
+  ${DIFF} prog.oku prog.out || Exit 1
 fi
-if test -z "$UTF8_LOCALE_UNSUPPORTED"; then
-  if test $LOCALE_FR_UTF8 != none; then
-    prepare_locale_ fr $LOCALE_FR_UTF8
-    LANGUAGE= LC_ALL=$LOCALE_FR_UTF8 python prog2.py 2 > prog.out || Exit 1
-    ${DIFF} prog.oku prog.out || Exit 1
+if test -z "$ISO8859_LOCALE_UNSUPPORTED"; then
+  if test $LOCALE_FR != none; then
+    prepare_locale_ fr $LOCALE_FR
+    LANGUAGE= LC_ALL=$LOCALE_FR python prog2.py 2 > prog.out || Exit 1
+    ${DIFF} prog.ok prog.out || Exit 1
   fi
   if test $LOCALE_FR = none && test $LOCALE_FR_UTF8 = none; then
     if test -f /usr/bin/localedef; then
@@ -123,11 +124,11 @@
     Exit 77
   fi
 else
-  if test $LOCALE_FR = none; then
+  if test $LOCALE_FR_UTF8 = none; then
     if test -f /usr/bin/localedef; then
-      echo "Skipping test: no traditional french locale is installed"
+      echo "Skipping test: no french Unicode locale is installed"
     else
-      echo "Skipping test: no traditional french locale is supported"
+      echo "Skipping test: no french Unicode locale is supported"
     fi
     Exit 77
   fi
--- gettext-tools/Makefile.in.orig	2023-12-02 21:46:40.000000000 +0000
+++ gettext-tools/Makefile.in	2023-12-02 21:47:08.000000000 +0000
@@ -3400,7 +3400,7 @@
 top_srcdir = @top_srcdir@
 AUTOMAKE_OPTIONS = 1.5 gnu no-dependencies
 ACLOCAL_AMFLAGS = -I m4 -I ../gettext-runtime/m4 -I ../m4 -I gnulib-m4 -I libgrep/gnulib-m4 -I libgettextpo/gnulib-m4
-SUBDIRS = gnulib-lib libgrep src libgettextpo po its projects styles emacs misc man m4 tests system-tests gnulib-tests examples doc
+SUBDIRS = gnulib-lib libgrep src libgettextpo po its projects styles emacs misc man m4 tests system-tests examples doc
 
 # Allow users to use "gnulib-tool --update".
 
--- gettext-runtime/config.h.in	2023-11-19 14:22:34.000000000 -0600
+++ gettext-runtime/config.h.in	2024-01-29 02:29:09.000000000 -0600
@@ -1421,7 +1421,7 @@
 #if (defined __has_attribute \
      && (!defined __clang_minor__ \
          || (defined __apple_build_version__ \
-             ? 6000000 <= __apple_build_version__ \
+             ? 7000000 <= __apple_build_version__ \
              : 5 <= __clang_major__)))
 # define _GL_HAS_ATTRIBUTE(attr) __has_attribute (__##attr##__)
 #else
--- gettext-runtime/gnulib-lib/cdefs.h	2023-09-18 15:35:08.000000000 -0500
+++ gettext-runtime/gnulib-lib/cdefs.h	2024-01-29 02:29:09.000000000 -0600
@@ -42,7 +42,7 @@
 #if (defined __has_attribute \
      && (!defined __clang_minor__ \
          || (defined __apple_build_version__ \
-             ? 6000000 <= __apple_build_version__ \
+             ? 7000000 <= __apple_build_version__ \
              : 3 < __clang_major__ + (5 <= __clang_minor__))))
 # define __glibc_has_attribute(attr) __has_attribute (attr)
 #else
--- gettext-runtime/intl/config.h.in	2023-11-19 14:22:28.000000000 -0600
+++ gettext-runtime/intl/config.h.in	2024-01-29 02:29:09.000000000 -0600
@@ -1151,7 +1151,7 @@
 #if (defined __has_attribute \
      && (!defined __clang_minor__ \
          || (defined __apple_build_version__ \
-             ? 6000000 <= __apple_build_version__ \
+             ? 7000000 <= __apple_build_version__ \
              : 5 <= __clang_major__)))
 # define _GL_HAS_ATTRIBUTE(attr) __has_attribute (__##attr##__)
 #else
--- gettext-runtime/libasprintf/config.h.in	2023-11-19 14:22:30.000000000 -0600
+++ gettext-runtime/libasprintf/config.h.in	2024-01-29 02:29:09.000000000 -0600
@@ -691,7 +691,7 @@
 #if (defined __has_attribute \
      && (!defined __clang_minor__ \
          || (defined __apple_build_version__ \
-             ? 6000000 <= __apple_build_version__ \
+             ? 7000000 <= __apple_build_version__ \
              : 5 <= __clang_major__)))
 # define _GL_HAS_ATTRIBUTE(attr) __has_attribute (__##attr##__)
 #else
--- gettext-tools/config.h.in	2023-11-19 14:23:03.000000000 -0600
+++ gettext-tools/config.h.in	2024-01-29 02:29:09.000000000 -0600
@@ -2986,7 +2986,7 @@
 #if (defined __has_attribute \
      && (!defined __clang_minor__ \
          || (defined __apple_build_version__ \
-             ? 6000000 <= __apple_build_version__ \
+             ? 7000000 <= __apple_build_version__ \
              : 5 <= __clang_major__)))
 # define _GL_HAS_ATTRIBUTE(attr) __has_attribute (__##attr##__)
 #else
--- gettext-tools/gnulib-lib/cdefs.h	2023-09-18 15:35:52.000000000 -0500
+++ gettext-tools/gnulib-lib/cdefs.h	2024-01-29 02:29:09.000000000 -0600
@@ -42,7 +42,7 @@
 #if (defined __has_attribute \
      && (!defined __clang_minor__ \
          || (defined __apple_build_version__ \
-             ? 6000000 <= __apple_build_version__ \
+             ? 7000000 <= __apple_build_version__ \
              : 3 < __clang_major__ + (5 <= __clang_minor__))))
 # define __glibc_has_attribute(attr) __has_attribute (attr)
 #else
--- gettext-tools/libgrep/cdefs.h	2023-09-18 15:36:21.000000000 -0500
+++ gettext-tools/libgrep/cdefs.h	2024-01-29 02:29:09.000000000 -0600
@@ -42,7 +42,7 @@
 #if (defined __has_attribute \
      && (!defined __clang_minor__ \
          || (defined __apple_build_version__ \
-             ? 6000000 <= __apple_build_version__ \
+             ? 7000000 <= __apple_build_version__ \
              : 3 < __clang_major__ + (5 <= __clang_minor__))))
 # define __glibc_has_attribute(attr) __has_attribute (attr)
 #else
--- libtextstyle/config.h.in	2023-11-19 14:22:53.000000000 -0600
+++ libtextstyle/config.h.in	2024-01-29 02:29:09.000000000 -0600
@@ -1392,7 +1392,7 @@
 #if (defined __has_attribute \
      && (!defined __clang_minor__ \
          || (defined __apple_build_version__ \
-             ? 6000000 <= __apple_build_version__ \
+             ? 7000000 <= __apple_build_version__ \
              : 5 <= __clang_major__)))
 # define _GL_HAS_ATTRIBUTE(attr) __has_attribute (__##attr##__)
 #else

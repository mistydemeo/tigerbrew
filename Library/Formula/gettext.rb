class Gettext < Formula
  desc "GNU internationalization (i18n) and localization (l10n) library"
  homepage "https://www.gnu.org/software/gettext/"
  url "https://ftpmirror.gnu.org/gettext/gettext-0.22.4.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gettext/gettext-0.22.4.tar.xz"
  sha256 "29217f1816ee2e777fa9a01f9956a14139c0c23cc1b20368f06b2888e8a34116"

  bottle do
    sha256 "c64bb31029e29599442653fe1e0f2216ae8fe144451a0541896f6e367df0018f" => :tiger_altivec
  end

  unless MacOS.version <= :leopard  # what Mac OS version would be correct here?
    keg_only :shadowed_by_osx, "OS X provides the BSD gettext library and some software gets confused if both are in the library path."
  end

  option :universal

  # Fix lang-python-* failures when a traditional French locale
  # https://git.savannah.gnu.org/gitweb/?p=gettext.git;a=patch;h=3c7e67be7d4dab9df362ab19f4f5fa3b9ca0836b
  # Skip the gnulib tests as they have their own set of problems which has nothing to do with what's being built.
  patch :p0, :DATA

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
 

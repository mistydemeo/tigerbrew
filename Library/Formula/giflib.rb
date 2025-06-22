class Giflib < Formula
  desc "GIF library using patented LZW algorithm"
  homepage "https://giflib.sourceforge.net/"
  url "https://prdownloads.sourceforge.net/project/giflib/giflib-5.2.1.tar.gz"
  sha256 "31da5562f44c5f15d63340a09a4fd62b48c45620cd302f77a6d9acf0077879bd"

  bottle do
    sha256 "924f16d9323e1380718228addc1dd09ce6091ed9a379951710c90af1813efba0" => :tiger_altivec
  end

  option :universal

  # Upstream has stripped out the previous autotools-based build system and their
  # Makefile doesn't work on macOS. See https://sourceforge.net/p/giflib/bugs/133/
  # https://sourceforge.net/p/giflib/bugs/_discuss/thread/4e811ad29b/c323/attachment/Makefile.patch
  patch :p0, :DATA

  def install
    ENV.universal_binary if build.universal?
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    # Pass CFLAGS to explicitly override the CFLAGS from the makefile,
    # which contains some flags that are incompatible with GCC 4.0/4.2
    system "make", "all", "CFLAGS=#{ENV.cflags}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    output = shell_output("#{bin}/giftext #{test_fixtures("test.gif")}")
    assert_match "Screen Size - Width = 1, Height = 1", output
  end
end
__END__
--- Makefile.orig	2019-06-24 17:08:57.000000000 +0100
+++ Makefile	2023-11-22 19:38:36.000000000 +0000
@@ -8,7 +8,7 @@
 #
 OFLAGS = -O0 -g
 OFLAGS  = -O2
-CFLAGS  = -std=gnu99 -fPIC -Wall -Wno-format-truncation $(OFLAGS)
+CFLAGS  ?= -std=gnu99 -fPIC -Wall -Wno-format-truncation $(OFLAGS)
 
 SHELL = /bin/sh
 TAR = tar
@@ -37,6 +37,8 @@
 UHEADERS = getarg.h
 UOBJECTS = $(USOURCES:.c=.o)
 
+UNAME:=$(shell uname)
+
 # Some utilities are installed
 INSTALLABLE = \
 	gif2rgb \
@@ -61,27 +63,53 @@
 
 LDLIBS=libgif.a -lm
 
-all: libgif.so libgif.a libutil.so libutil.a $(UTILS)
+SOEXTENION	= so
+LIBGIFSO	= libgif.$(SOEXTENSION)
+LIBGIFSOMAJOR	= libgif.$(SOEXTENSION).$(LIBMAJOR)
+LIBGIFSOVER	= libgif.$(SOEXTENSION).$(LIBVER)
+LIBUTILSO	= libutil.$(SOEXTENSION)
+LIBUTILSOMAJOR	= libutil.$(SOEXTENSION).$(LIBMAJOR)
+ifeq ($(UNAME), Darwin)
+SOEXTENSION	= dylib
+LIBGIFSO        = libgif.$(SOEXTENSION)
+LIBGIFSOMAJOR   = libgif.$(LIBMAJOR).$(SOEXTENSION)
+LIBGIFSOVER	= libgif.$(LIBVER).$(SOEXTENSION)
+LIBUTILSO	= libutil.$(SOEXTENSION)
+LIBUTILSOMAJOR	= libutil.$(LIBMAJOR).$(SOEXTENSION)
+endif
+
+all: $(LIBGIFSO) libgif.a $(LIBUTILSO) libutil.a $(UTILS)
+ifeq ($(UNAME), Darwin)
+else
 	$(MAKE) -C doc
+endif
 
 $(UTILS):: libgif.a libutil.a
 
-libgif.so: $(OBJECTS) $(HEADERS)
-	$(CC) $(CFLAGS) -shared $(LDFLAGS) -Wl,-soname -Wl,libgif.so.$(LIBMAJOR) -o libgif.so $(OBJECTS)
+$(LIBGIFSO): $(OBJECTS) $(HEADERS)
+ifeq ($(UNAME), Darwin)
+	$(CC) $(CFLAGS) -dynamiclib -current_version $(LIBVER) $(OBJECTS) -o $(LIBGIFSO)
+else
+	$(CC) $(CFLAGS) -shared $(LDFLAGS) -Wl,-soname -Wl,$(LIBGIFSOMAJOR) -o $(LIBGIFSO) $(OBJECTS)
+endif
 
 libgif.a: $(OBJECTS) $(HEADERS)
 	$(AR) rcs libgif.a $(OBJECTS)
 
-libutil.so: $(UOBJECTS) $(UHEADERS)
-	$(CC) $(CFLAGS) -shared $(LDFLAGS) -Wl,-soname -Wl,libutil.so.$(LIBMAJOR) -o libutil.so $(UOBJECTS)
+$(LIBUTILSO): $(UOBJECTS) $(UHEADERS)
+ifeq ($(UNAME), Darwin)
+	$(CC) $(CFLAGS) -dynamiclib -current_version $(LIBVER) $(OBJECTS) -o $(LIBUTILSO)
+else
+	$(CC) $(CFLAGS) -shared $(LDFLAGS) -Wl,-soname -Wl,$(LIBUTILMAJOR) -o $(LIBUTILSO) $(UOBJECTS)
+endif
 
 libutil.a: $(UOBJECTS) $(UHEADERS)
 	$(AR) rcs libutil.a $(UOBJECTS)
 
 clean:
-	rm -f $(UTILS) $(TARGET) libgetarg.a libgif.a libgif.so libutil.a libutil.so *.o
-	rm -f libgif.so.$(LIBMAJOR).$(LIBMINOR).$(LIBPOINT)
-	rm -f libgif.so.$(LIBMAJOR)
+	rm -f $(UTILS) $(TARGET) libgetarg.a libgif.a $(LIBGIFSO) libutil.a $(LIBUTILSO) *.o
+	rm -f $(LIBGIFSOVER)
+	rm -f $(LIBGIFSOMAJOR)
 	rm -fr doc/*.1 *.html doc/staging
 
 check: all
@@ -89,7 +117,12 @@
 
 # Installation/uninstallation
 
+ifeq ($(UNAME), Darwin)
+install: all install-bin install-include install-lib
+else
 install: all install-bin install-include install-lib install-man
+endif
+
 install-bin: $(INSTALLABLE)
 	$(INSTALL) -d "$(DESTDIR)$(BINDIR)"
 	$(INSTALL) $^ "$(DESTDIR)$(BINDIR)"
@@ -99,9 +132,9 @@
 install-lib:
 	$(INSTALL) -d "$(DESTDIR)$(LIBDIR)"
 	$(INSTALL) -m 644 libgif.a "$(DESTDIR)$(LIBDIR)/libgif.a"
-	$(INSTALL) -m 755 libgif.so "$(DESTDIR)$(LIBDIR)/libgif.so.$(LIBVER)"
-	ln -sf libgif.so.$(LIBVER) "$(DESTDIR)$(LIBDIR)/libgif.so.$(LIBMAJOR)"
-	ln -sf libgif.so.$(LIBMAJOR) "$(DESTDIR)$(LIBDIR)/libgif.so"
+	$(INSTALL) -m 755 $(LIBGIFSO) "$(DESTDIR)$(LIBDIR)/$(LIBGIFSOVER)"
+	ln -sf $(LIBGIFSOVER) "$(DESTDIR)$(LIBDIR)/$(LIBGIFSOMAJOR)"
+	ln -sf $(LIBGIFSOMAJOR) "$(DESTDIR)$(LIBDIR)/$(LIBGIFSO)"
 install-man:
 	$(INSTALL) -d "$(DESTDIR)$(MANDIR)/man1"
 	$(INSTALL) -m 644 doc/*.1 "$(DESTDIR)$(MANDIR)/man1"
@@ -112,7 +145,7 @@
 	rm -f "$(DESTDIR)$(INCDIR)/gif_lib.h"
 uninstall-lib:
 	cd "$(DESTDIR)$(LIBDIR)" && \
-		rm -f libgif.a libgif.so libgif.so.$(LIBMAJOR) libgif.so.$(LIBVER)
+		rm -f libgif.a $(LIBGIFSO) $(LIBGIFSOMAJOR) $(LIBGIFSOVER)
 uninstall-man:
 	cd "$(DESTDIR)$(MANDIR)/man1" && rm -f $(shell cd doc >/dev/null && echo *.1)
 

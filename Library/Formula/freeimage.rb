class FreeimageHttpDownloadStrategy < CurlDownloadStrategy
  def stage
    # need to convert newlines or patch chokes
    quiet_safe_system "/usr/bin/unzip", { :quiet_flag => "-qq" }, "-aa", cached_location
    chdir
  end
end

class Freeimage < Formula
  desc "Library for FreeImage, a dependency-free graphics library"
  homepage "https://sourceforge.net/projects/freeimage"
  url "https://downloads.sourceforge.net/project/freeimage/Source%20Distribution/3.17.0/FreeImage3170.zip",
    :using => FreeimageHttpDownloadStrategy
  version "3.17.0"
  sha256 "fbfc65e39b3d4e2cb108c4ffa8c41fd02c07d4d436c594fff8dab1a6d5297f89"


  option :universal

  patch :DATA

  def install
    ENV.universal_binary if build.universal?
    system "make", "-f", "Makefile.gnu"
    system "make", "-f", "Makefile.gnu", "install", "PREFIX=#{prefix}"
    system "make", "-f", "Makefile.fip"
    system "make", "-f", "Makefile.fip", "install", "PREFIX=#{prefix}"
  end
end

__END__
diff --git a/Makefile.fip b/Makefile.fip
old mode 100755
new mode 100644
index b59c419..6e177fc
--- a/Makefile.fip
+++ b/Makefile.fip
@@ -5,8 +5,9 @@ include fipMakefile.srcs
 
 # General configuration variables:
 DESTDIR ?= /
-INCDIR ?= $(DESTDIR)/usr/include
-INSTALLDIR ?= $(DESTDIR)/usr/lib
+PREFIX ?= /usr/local
+INCDIR ?= $(DESTDIR)$(PREFIX)/include
+INSTALLDIR ?= $(DESTDIR)$(PREFIX)/lib
 
 # Converts cr/lf to just lf
 DOS2UNIX = dos2unix
@@ -35,9 +36,9 @@ endif
 
 TARGET  = freeimageplus
 STATICLIB = lib$(TARGET).a
-SHAREDLIB = lib$(TARGET)-$(VER_MAJOR).$(VER_MINOR).so
-LIBNAME	= lib$(TARGET).so
-VERLIBNAME = $(LIBNAME).$(VER_MAJOR)
+SHAREDLIB = lib$(TARGET).$(VER_MAJOR).$(VER_MINOR).dylib
+LIBNAME	= lib$(TARGET).dylib
+VERLIBNAME = lib$(TARGET).$(VER_MAJOR).dylib
 HEADER = Source/FreeImage.h
 HEADERFIP = Wrapper/FreeImagePlus/FreeImagePlus.h
 
@@ -49,7 +50,7 @@ all: dist
 dist: FreeImage
	mkdir -p Dist
	cp *.a Dist/
-	cp *.so Dist/
+	cp *.dylib Dist/
	cp Source/FreeImage.h Dist/
	cp Wrapper/FreeImagePlus/FreeImagePlus.h Dist/

@@ -68,14 +69,15 @@ $(STATICLIB): $(MODULES)
 	$(AR) r $@ $(MODULES)
 
 $(SHAREDLIB): $(MODULES)
-	$(CC) -s -shared -Wl,-soname,$(VERLIBNAME) $(LDFLAGS) -o $@ $(MODULES) $(LIBRARIES)
+	$(CXX) -dynamiclib -install_name $(LIBNAME) -current_version $(VER_MAJOR).$(VER_MINOR) -compatibility_version $(VER_MAJOR) $(LDFLAGS) -o $@ $(MODULES)
 
 install:
 	install -d $(INCDIR) $(INSTALLDIR)
-	install -m 644 -o root -g root $(HEADER) $(INCDIR)
-	install -m 644 -o root -g root $(HEADERFIP) $(INCDIR)
-	install -m 644 -o root -g root $(STATICLIB) $(INSTALLDIR)
-	install -m 755 -o root -g root $(SHAREDLIB) $(INSTALLDIR)
+	install -m 644 $(HEADER) $(INCDIR)
+	install -m 644 $(HEADERFIP) $(INCDIR)
+	install -m 644 $(STATICLIB) $(INSTALLDIR)
+	install -m 755 $(SHAREDLIB) $(INSTALLDIR)
+	ln -s $(SHAREDLIB) $(INSTALLDIR)/$(LIBNAME)
	ln -sf $(SHAREDLIB) $(INSTALLDIR)/$(VERLIBNAME)
	ln -sf $(VERLIBNAME) $(INSTALLDIR)/$(LIBNAME)

diff --git a/Makefile.gnu b/Makefile.gnu
old mode 100755
new mode 100644
index 92f6358..264b70f
--- a/Makefile.gnu
+++ b/Makefile.gnu
@@ -5,8 +5,9 @@ include Makefile.srcs
 
 # General configuration variables:
 DESTDIR ?= /
-INCDIR ?= $(DESTDIR)/usr/include
-INSTALLDIR ?= $(DESTDIR)/usr/lib
+PREFIX ?= /usr/local
+INCDIR ?= $(DESTDIR)$(PREFIX)/include
+INSTALLDIR ?= $(DESTDIR)$(PREFIX)/lib
 
 # Converts cr/lf to just lf
 DOS2UNIX = dos2unix
@@ -35,9 +36,9 @@ endif
 
 TARGET  = freeimage
 STATICLIB = lib$(TARGET).a
-SHAREDLIB = lib$(TARGET)-$(VER_MAJOR).$(VER_MINOR).so
-LIBNAME	= lib$(TARGET).so
-VERLIBNAME = $(LIBNAME).$(VER_MAJOR)
+SHAREDLIB = lib$(TARGET).$(VER_MAJOR).$(VER_MINOR).dylib
+LIBNAME	= lib$(TARGET).dylib
+VERLIBNAME = lib$(TARGET).$(VER_MAJOR).dylib
 HEADER = Source/FreeImage.h
 
 
@@ -49,7 +50,7 @@ all: dist
 dist: FreeImage
	mkdir -p Dist
	cp *.a Dist/
-	cp *.so Dist/
+	cp *.dylib Dist/
	cp Source/FreeImage.h Dist/
 
 dos2unix:
@@ -67,13 +68,13 @@ $(STATICLIB): $(MODULES)
 	$(AR) r $@ $(MODULES)
 
 $(SHAREDLIB): $(MODULES)
-	$(CC) -s -shared -Wl,-soname,$(VERLIBNAME) $(LDFLAGS) -o $@ $(MODULES) $(LIBRARIES)
+	$(CXX) -dynamiclib -install_name $(LIBNAME) -current_version $(VER_MAJOR).$(VER_MINOR) -compatibility_version $(VER_MAJOR) $(LDFLAGS) -o $@ $(MODULES)
 
 install:
 	install -d $(INCDIR) $(INSTALLDIR)
-	install -m 644 -o root -g root $(HEADER) $(INCDIR)
-	install -m 644 -o root -g root $(STATICLIB) $(INSTALLDIR)
-	install -m 755 -o root -g root $(SHAREDLIB) $(INSTALLDIR)
+	install -m 644 $(HEADER) $(INCDIR)
+	install -m 644 $(STATICLIB) $(INSTALLDIR)
+	install -m 755 $(SHAREDLIB) $(INSTALLDIR)
 	ln -sf $(SHAREDLIB) $(INSTALLDIR)/$(VERLIBNAME)
 	ln -sf $(VERLIBNAME) $(INSTALLDIR)/$(LIBNAME)	
 #	ldconfig

require 'formula'

# Note that cctools newer than 806 cannot build for PPC or for Tiger.
# Leopard+ users: submit a formula for a conditional
# newer version if you like.
#
# TODO: LLVM builds not supported yet.
class Cctools < Formula
  homepage 'http://opensource.apple.com/'
  url 'http://www.opensource.apple.com/tarballs/cctools/cctools-806.tar.gz'
  sha1 'e4f9a7ee0eef930e81d50b6b7300b8ddc1c7b341'

  bottle do
    sha1 "049866feb149128c031c37521f7be166435c6c15" => :tiger_g4e
    sha1 "6ec31fb6615accabf3a3defebd367e5cc7f78ffa" => :tiger_altivec
    sha1 "fc953e9dec74facebed0319911690769621dff09" => :leopard_g3
    sha1 "e51879f08bc81e9d1f59ba8333c5f3292ef62548" => :leopard_altivec
  end

  depends_on 'cctools-headers' => :build
  depends_on 'ld64' => :build

  keg_only :provided_by_osx,
    "These modern versions of the tools were shipped with Xcode 4.1."

  def patches
    {
      :p0 => [
        'https://trac.macports.org/export/103959/trunk/dports/devel/cctools/files/cctools-806-lto.patch',
        'https://trac.macports.org/export/103959/trunk/dports/devel/cctools/files/PR-9087924.patch',
        'https://trac.macports.org/export/103959/trunk/dports/devel/cctools/files/PR-9830754.patch',
        # Despite the patch name this is needed on 806 too
        'https://trac.macports.org/export/103985/trunk/dports/devel/cctools/files/cctools-822-no-lto.patch',
        'https://trac.macports.org/export/103959/trunk/dports/devel/cctools/files/PR-11136237.patch',
        'https://trac.macports.org/export/103959/trunk/dports/devel/cctools/files/PR-12475288.patch'
      ],
      # fixes up hardcoded paths in Makefiles
      :p1 => DATA
    }
  end

  def install
    ENV.j1 # see https://github.com/mistydemeo/tigerbrew/issues/102

    chmod 0755, 'libmacho/Makefile'
    inreplace 'libmacho/Makefile', '@PREFIX@', prefix

    args = %W[
      RC_ProjectSourceVersion=#{version}
      USE_DEPENDENCY_FILE=NO
      BUILD_DYLIBS=NO
      CC=#{ENV.cc}
      CXX=#{ENV.cxx}
      LTO=
      RC_CFLAGS=#{ENV.cflags}
      TRIE=
      RC_OS="macos"
      DSTROOT=#{prefix}
    ]

    if Hardware.cpu_type == :intel
      archs = "i386 x86_64"
    else
      archs = "ppc i386 x86_64"
    end
    args << "RC_ARCHS=#{archs}"

    system "make", "install_tools", *args
  end

  def caveats; <<-EOS.undent
    cctools's version of ld was not built; ld64 is used instead.
    EOS
  end
end

__END__
diff --git a/Makefile b/Makefile
index 837cdc3..b85ff3e 100644
--- a/Makefile
+++ b/Makefile
@@ -28,7 +28,6 @@ INSTALLSRC_SUBDIRS = $(COMMON_SUBDIRS) $(SUBDIRS_32) ar include efitools \
 		     libmacho
 COMMON_SUBDIRS = libstuff as gprof misc RelNotes man cbtlibs otool
 APPLE_SUBDIRS = ar
-SUBDIRS_32 = ld
 
 ifeq "macos" "$(RC_OS)"
   OLD_LIBKLD := $(shell if [ "$(RC_MAJOR_RELEASE_TRAIN)" = "Tiger" ] || \
diff --git a/RelNotes/Makefile b/RelNotes/Makefile
index 4f47d7c..6544a7f 100644
--- a/RelNotes/Makefile
+++ b/RelNotes/Makefile
@@ -29,7 +29,7 @@ ifeq "macos" "$(RC_OS)"
 else
   NOTESDIR = /System/Documentation/Developer/ReleaseNotes
 endif
-PRIVATE_NOTESDIR = /usr/local/RelNotes
+PRIVATE_NOTESDIR = /RelNotes
 
 install: ${COMPILERTOOLS_NOTES} ${PREBINDING_NOTES} ${PRIVATE_NOTES}
 	$(MKDIRS) '${DSTROOT}${NOTESDIR}'
diff --git a/ar/Makefile b/ar/Makefile
index 0e1e388..5e3d501 100644
--- a/ar/Makefile
+++ b/ar/Makefile
@@ -28,8 +28,8 @@ SYMROOT = .
 OFILE_DIR = $(OBJROOT)
 VPATH = $(OFILE_DIR)
 
-BINDIR = /usr/bin
-MANDIR = /usr/share/man
+BINDIR = /bin
+MANDIR = /share/man
 DSTDIRS = $(DSTROOT)$(BINDIR) $(DSTROOT)$(MANDIR)/man1 $(DSTROOT)$(MANDIR)/man5
 
 HFILES = archive.h extern.h pathnames.h
@@ -70,7 +70,7 @@ shlib_clean:
 install: $(RC_OS)
 
 teflon macos: all $(DSTDIRS)
-	install -c -s -m 555 $(SYMROOT)/$(PRODUCT).NEW \
+	install -c -m 555 $(SYMROOT)/$(PRODUCT).NEW \
 		$(DSTROOT)$(BINDIR)/$(PRODUCT)
 	install -c -m 444 $(MAN1) $(DSTROOT)$(MANDIR)/man1
 	install -c -m 444 $(MAN5) $(DSTROOT)$(MANDIR)/man5
diff --git a/as/Makefile b/as/Makefile
index 9c32c58..360997d 100644
--- a/as/Makefile
+++ b/as/Makefile
@@ -56,23 +56,23 @@ OFILE_DIRS = $(OBJROOT)/driver_dir \
 	     $(OBJROOT)/aarm_dir
 
 BINDIR = /bin
-USRBINDIR = /usr/bin
+USRBINDIR = /bin
 ifeq "macos" "$(RC_OS)"
        LIBDIR := $(shell if [ "$(RC_RELEASE)" = "Beaker" ] ||    \
 			    [ "$(RC_RELEASE)" = "Bunsen" ] ||    \
 			    [ "$(RC_RELEASE)" = "Gonzo"  ] ||    \
 			    [ "$(RC_RELEASE)" = "Kodiak" ]; then \
-	     echo /usr/libexec; else echo /usr/libexec/gcc/darwin; \
+	     echo /libexec; else echo /libexec/gcc/darwin; \
 	     fi; )
        LOCLIBDIR := $(shell if [ "$(RC_RELEASE)" = "Beaker" ] ||    \
 			       [ "$(RC_RELEASE)" = "Bunsen" ] ||    \
 			       [ "$(RC_RELEASE)" = "Gonzo"  ] ||    \
 			       [ "$(RC_RELEASE)" = "Kodiak" ]; then \
-	     echo /usr/local/libexec; else echo /usr/local/libexec/gcc/darwin; \
+	     echo /libexec; else echo /libexec/gcc/darwin; \
 	     fi; )
 else
-  LIBDIR = /usr/libexec
-  LOCLIBDIR = /usr/local/libexec
+  LIBDIR = /libexec
+  LOCLIBDIR = /libexec
 endif
 
 DWARF = dwarf2dbg.c
@@ -425,66 +425,66 @@ install: all $(RC_OS)_install
 
 macos_install: common_install xcommon_install
 	$(MKDIRS) $(DSTROOT)$(LIBDIR)/i386
-	install -c -s -m 555 $(SYMROOT)/a386_dir/as \
+	install -c -m 555 $(SYMROOT)/a386_dir/as \
 		$(DSTROOT)$(LIBDIR)/i386/as
 	$(MKDIRS) $(DSTROOT)$(LIBDIR)/x86_64
-	install -c -s -m 555 $(SYMROOT)/ax86_64_dir/as \
+	install -c -m 555 $(SYMROOT)/ax86_64_dir/as \
 		$(DSTROOT)$(LIBDIR)/x86_64/as
 
 teflon_install: common_install xcommon_install
 	$(MKDIRS) $(DSTROOT)$(LIBDIR)/i386
-	install -c -s -m 555 $(SYMROOT)/a386_dir/as \
+	install -c -m 555 $(SYMROOT)/a386_dir/as \
 		$(DSTROOT)$(LIBDIR)/i386/as
 
 xcommon_install:
 	$(MKDIRS) $(DSTROOT)$(USRBINDIR)
-	install -c -s -m 555 $(SYMROOT)/driver_dir/driver \
+	install -c -m 555 $(SYMROOT)/driver_dir/driver \
 		$(DSTROOT)$(USRBINDIR)/as	
 	$(MKDIRS) $(DSTROOT)/usr/local/OpenSourceVersions/
-	install -c -s -m 444 $(SRCROOT)/cctools.plist \
+	install -c -m 444 $(SRCROOT)/cctools.plist \
 		$(DSTROOT)/usr/local/OpenSourceVersions/cctools.plist
 	$(MKDIRS) $(DSTROOT)/usr/local/OpenSourceLicenses/
-	install -c -s -m 444 $(SRCROOT)/COPYING \
+	install -c -m 444 $(SRCROOT)/COPYING \
 		$(DSTROOT)/usr/local/OpenSourceLicenses/cctools.txt
 	$(MKDIRS) $(DSTROOT)$(LOCLIBDIR)/ppc
-	install -c -s -m 555 $(SYMROOT)/appc_dir/as \
+	install -c -m 555 $(SYMROOT)/appc_dir/as \
 		$(DSTROOT)$(LOCLIBDIR)/ppc/as
 	$(MKDIRS) $(DSTROOT)$(LOCLIBDIR)/ppc64
-	install -c -s -m 555 $(SYMROOT)/appc64_dir/as \
+	install -c -m 555 $(SYMROOT)/appc64_dir/as \
 		$(DSTROOT)$(LOCLIBDIR)/ppc64/as
 	$(MKDIRS) $(DSTROOT)$(LOCLIBDIR)/m68k
-	install -c -s -m 555 $(SYMROOT)/a68_dir/as \
+	install -c -m 555 $(SYMROOT)/a68_dir/as \
 		$(DSTROOT)$(LOCLIBDIR)/m68k/as
 	$(MKDIRS) $(DSTROOT)$(LOCLIBDIR)/sparc 
-	install -c -s -m 555 $(SYMROOT)/asparc_dir/as \
+	install -c -m 555 $(SYMROOT)/asparc_dir/as \
 		$(DSTROOT)$(LOCLIBDIR)/sparc/as
 	$(MKDIRS) $(DSTROOT)$(LIBDIR)/arm
-	install -c -s -m 555 $(SYMROOT)/aarm_dir/as \
+	install -c -m 555 $(SYMROOT)/aarm_dir/as \
 		$(DSTROOT)$(LIBDIR)/arm/as
 
 nextstep_install: common_install
 	$(MKDIRS) $(DSTROOT)$(BINDIR)
-	install -c -s -m 555 $(SYMROOT)/driver_dir/driver \
+	install -c -m 555 $(SYMROOT)/driver_dir/driver \
 		$(DSTROOT)$(BINDIR)/as	
 	$(MKDIRS) $(DSTROOT)$(LIBDIR)/m68k
-	install -c -s -m 555 $(SYMROOT)/a68_dir/as \
+	install -c -m 555 $(SYMROOT)/a68_dir/as \
 		$(DSTROOT)$(LIBDIR)/m68k/as
 	$(MKDIRS) $(DSTROOT)$(LIBDIR)/i386
-	install -c -s -m 555 $(SYMROOT)/a386_dir/as \
+	install -c -m 555 $(SYMROOT)/a386_dir/as \
 		$(DSTROOT)$(LIBDIR)/i386/as
 	$(MKDIRS) $(DSTROOT)$(LIBDIR)/sparc
-	install -c -s -m 555 $(SYMROOT)/asparc_dir/as \
+	install -c -m 555 $(SYMROOT)/asparc_dir/as \
 		$(DSTROOT)$(LIBDIR)/sparc/as
 	$(MKDIRS) $(DSTROOT)$(LOCLIBDIR)/ppc
-	install -c -s -m 555 $(SYMROOT)/appc_dir/as \
+	install -c -m 555 $(SYMROOT)/appc_dir/as \
 		$(DSTROOT)$(LOCLIBDIR)/ppc/as
 
 common_install:
 	$(MKDIRS) $(DSTROOT)$(LOCLIBDIR)/m88k
-	install -c -s -m 555 $(SYMROOT)/a88_dir/as \
+	install -c -m 555 $(SYMROOT)/a88_dir/as \
 		$(DSTROOT)$(LOCLIBDIR)/m88k/as
 	$(MKDIRS) $(DSTROOT)$(LOCLIBDIR)/hppa
-	install -c -s -m 555 $(SYMROOT)/ahppa_dir/as \
+	install -c -m 555 $(SYMROOT)/ahppa_dir/as \
 		$(DSTROOT)$(LOCLIBDIR)/hppa/as
 	$(MKDIRS) $(DSTROOT)$(LOCLIBDIR)/i860
 	install -s -m 555 $(SYMROOT)/a860_dir/as \
diff --git a/cbtlibs/Makefile b/cbtlibs/Makefile
index 08038fd..cbd9acf 100644
--- a/cbtlibs/Makefile
+++ b/cbtlibs/Makefile
@@ -30,7 +30,7 @@ VPATH = $(OFILE_DIR)
 CFILES = libsyminfo.c
 OBJS = $(CFILES:.c=.o)
 INSTALL_FILES = $(CFILES) Makefile notes
-LOCLIBDIR = /usr/local/lib
+LOCLIBDIR = /lib
 LIBSTUFF = -L$(SYMROOT)/../libstuff -lstuff
 
 all: $(OFILE_DIR) $(SYMROOT) lib_ofiles
diff --git a/efitools/Makefile b/efitools/Makefile
old mode 100644
new mode 100755
index 02ca1de..bc6a167
--- a/efitools/Makefile
+++ b/efitools/Makefile
@@ -34,7 +34,7 @@ OFILE_DIR = $(OBJROOT)
 VPATH = $(OFILE_DIR)
 SYMROOT = .
 
-EFIBINDIR = /usr/local/efi/bin
+EFIBINDIR = /bin
 
 CFILES = makerelocs.c mtoc.c
 
@@ -96,7 +96,7 @@ install:
 # builds.
 #	install -c -s -m 555 $(SYMROOT)/makerelocs.NEW \
 #		$(DSTROOT)$(EFIBINDIR)/makerelocs
-	install -c -s -m 555 $(SYMROOT)/mtoc.NEW \
+	install -c -m 555 $(SYMROOT)/mtoc.NEW \
 		$(DSTROOT)$(EFIBINDIR)/mtoc
 
 installsrc:
diff --git a/gprof/Makefile b/gprof/Makefile
old mode 100644
new mode 100755
index 96909fd..a40b882
--- a/gprof/Makefile
+++ b/gprof/Makefile
@@ -28,11 +28,11 @@ OFILE_DIR = $(OBJROOT)
 VPATH = $(OFILE_DIR)
 SYMROOT = .
 
-BINDIR = /usr/ucb
-USRBINDIR = /usr/bin
-nextstep_LIBDIR = /usr/lib
-teflon_LIBDIR   = /usr/share
-macos_LIBDIR    = /usr/share
+BINDIR = /ucb
+USRBINDIR = /bin
+nextstep_LIBDIR = /lib
+teflon_LIBDIR   = /share
+macos_LIBDIR    = /share
 
 HFILES = gprof.h m68k.h vax.h
 CFILES = gprof.c arcs.c dfn.c lookup.c calls.c hertz.c printgprof.c \
@@ -73,12 +73,12 @@ install: all common_install $(RC_OS)_install
 
 teflon_install macos_install:
 	$(MKDIRS) $(DSTROOT)$(USRBINDIR)
-	install -c -s -m 555 $(SYMROOT)/$(PRODUCT).NEW \
+	install -c -m 555 $(SYMROOT)/$(PRODUCT).NEW \
 		$(DSTROOT)$(USRBINDIR)/$(PRODUCT)
 
 nextstep_install:
 	$(MKDIRS) $(DSTROOT)$(BINDIR)
-	install -c -s -m 555 $(SYMROOT)/$(PRODUCT).NEW \
+	install -c -m 555 $(SYMROOT)/$(PRODUCT).NEW \
 		$(DSTROOT)$(BINDIR)/$(PRODUCT)
 
 common_install:
diff --git a/include/Makefile b/include/Makefile
index c70bfe4..2e55e9f 100644
--- a/include/Makefile
+++ b/include/Makefile
@@ -74,14 +74,14 @@ ifeq "macos" "$(RC_OS)"
 			    [ "$(RC_RELEASE)" = "Gonzo"  ] ||    \
 			    [ "$(RC_RELEASE)" = "Kodiak" ]; then \
 	 echo /System/Library/Frameworks/System.framework/Versions/B/Headers; \
-	 else echo /usr/include; \
+	 else echo /include; \
 	 fi; )
  macos_LOCINCDIR := $(shell if [ "$(RC_RELEASE)" = "Beaker" ] ||    \
 			       [ "$(RC_RELEASE)" = "Bunsen" ] ||    \
 			       [ "$(RC_RELEASE)" = "Gonzo"  ] ||    \
 			       [ "$(RC_RELEASE)" = "Kodiak" ]; then \
  echo /System/Library/Frameworks/System.framework/Versions/B/PrivateHeaders; \
- else echo /usr/local/include; \
+ else echo /include; \
  fi; )
 else
   macos_INCDIR = /System/Library/Frameworks/System.framework/Versions/B/Headers
diff --git a/libmacho/Makefile b/libmacho/Makefile
index b518030..ee52642 100644
--- a/libmacho/Makefile
+++ b/libmacho/Makefile
@@ -72,11 +72,11 @@ ifeq "macos" "$(RC_OS)"
   ARCHIVEDIR := $(shell if [ "$(RC_RELEASE)" = "Beaker" ] || \
 			   [ "$(RC_RELEASE)" = "Bunsen" ] || \
 			   [ "$(RC_RELEASE)" = "Gonzo" ]; then \
-	 echo /Local/Developer/System; else echo /usr/local/lib/system; fi; )
+	 echo /Local/Developer/System; else echo /lib/system; fi; )
 else
   ARCHIVEDIR = /Local/Developer/System
 endif
-DYLIBDIR = /usr/lib/system
+DYLIBDIR = /lib/system
 
 CFILES = arch.c getsecbyname.c getsegbyname.c get_end.c \
 	 swap.c hppa_swap.c i386_swap.c m68k_swap.c sparc_swap.c \
@@ -141,7 +141,7 @@ profile_ofiles:	$(OBJROOT)/profile_obj $(OBJROOT)/ptmp_obj
 	then								\
 	    (cd ptmp_obj;						\
 		$(MAKE) -f ../Makefile libmacho_pg.a libmacho_profile.dylib \
-		INSTALL_NAME=/usr/lib/system/libmacho_profile.dylib	\
+		INSTALL_NAME=@PREFIX@/lib/system/libmacho_profile.dylib	\
 		VPATH=.. 						\
 		OFILE_DIR=.						\
 		SRCROOT=..						\
@@ -160,7 +160,7 @@ profile_ofiles:	$(OBJROOT)/profile_obj $(OBJROOT)/ptmp_obj
 	    (cd $(OBJROOT)/ptmp_obj;					\
 		$(MAKE) -f $(SRCROOT)/Makefile libmacho_pg.a		\
 		libmacho_profile.dylib					\
-		INSTALL_NAME=/usr/lib/system/libmacho_profile.dylib	\
+		INSTALL_NAME=@PREFIX@/lib/system/libmacho_profile.dylib	\
 		VPATH=$(SRCROOT)					\
 		OFILE_DIR=$(OBJROOT)/ptmp_obj				\
 		SRCROOT=$(SRCROOT)					\
@@ -256,7 +256,7 @@ dynamic_ofiles: $(OBJROOT)/dynamic_obj $(OBJROOT)/dtmp_obj
 	then								\
 	    (cd dtmp_obj;						\
 		$(MAKE) -f ../Makefile libmacho.a libmacho.dylib	\
-		INSTALL_NAME=/usr/lib/system/libmacho.dylib		\
+		INSTALL_NAME=@PREFIX@/lib/system/libmacho.dylib		\
 		VPATH=.. 						\
 		OFILE_DIR=.						\
 		SRCROOT=..						\
@@ -267,7 +267,7 @@ dynamic_ofiles: $(OBJROOT)/dynamic_obj $(OBJROOT)/dtmp_obj
 		RC_ARCHS="$(RC_ARCHS)");				\
 	    (cd dtmp_obj;						\
 		$(MAKE) -f ../Makefile libmacho_debug.dylib		\
-		INSTALL_NAME=/usr/lib/system/libmacho_debug.dylib	\
+		INSTALL_NAME=@PREFIX@/lib/system/libmacho_debug.dylib	\
 		VPATH=.. 						\
 		OFILE_DIR=.						\
 		SRCROOT=..						\
@@ -283,7 +283,7 @@ dynamic_ofiles: $(OBJROOT)/dynamic_obj $(OBJROOT)/dtmp_obj
 	else								\
 	    (cd $(OBJROOT)/dtmp_obj;					\
 		$(MAKE) -f $(SRCROOT)/Makefile libmacho.a libmacho.dylib \
-		INSTALL_NAME=/usr/lib/system/libmacho.dylib		\
+		INSTALL_NAME=@PREFIX@/lib/system/libmacho.dylib		\
 		VPATH=$(SRCROOT)					\
 		OFILE_DIR=$(OBJROOT)/dtmp_obj				\
 		SRCROOT=$(SRCROOT)					\
@@ -295,7 +295,7 @@ dynamic_ofiles: $(OBJROOT)/dynamic_obj $(OBJROOT)/dtmp_obj
 		RC_ARCHS="$(RC_ARCHS)");				\
 	    (cd $(OBJROOT)/dtmp_obj;					\
 		$(MAKE) -f $(SRCROOT)/Makefile libmacho_debug.dylib	\
-		INSTALL_NAME=/usr/lib/system/libmacho_debug.dylib	\
+		INSTALL_NAME=@PREFIX@/lib/system/libmacho_debug.dylib	\
 		VPATH=$(SRCROOT)					\
 		OFILE_DIR=$(OBJROOT)/dtmp_obj				\
 		SRCROOT=$(SRCROOT)					\
diff --git a/man/Makefile b/man/Makefile
index d540960..e9851c0 100644
--- a/man/Makefile
+++ b/man/Makefile
@@ -27,9 +27,9 @@ MANL3 = libsyminfo.3 redo_prebinding.3
 INSTALL_FILES = Makefile $(COMMON_MAN1) $(MAN3) $(MAN5) $(MANL) \
 		$(MANL3) $(DYLD_MAN1) $(DYLD_MAN3) $(DYLD_MANL3) $(EFI1) notes
 
-MANDIR = /usr/share/man
-LOCMANDIR = /usr/local/man
-EFIMANDIR = /usr/local/efi/share/man
+MANDIR = /share/man
+LOCMANDIR = /share/man
+EFIMANDIR = /share/man
 DSTDIRS = $(DSTROOT)$(MANDIR)/man1 $(DSTROOT)$(MANDIR)/man3 \
 	  $(DSTROOT)$(MANDIR)/man5 $(DSTROOT)$(LOCMANDIR)/man1 \
 	  $(DSTROOT)$(LOCMANDIR)/man3 $(DSTROOT)$(EFIMANDIR)/man1
diff --git a/misc/Makefile b/misc/Makefile
index 4371f76..ce906fb 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -28,7 +28,7 @@ LIBSTUFF = -L$(SYMROOT)/../libstuff -lstuff
 ifeq "" "$(TRIE)"
   LIB_PRUNETRIE =
   else
-  LIB_PRUNETRIE = /usr/local/lib/libprunetrie.a
+  LIB_PRUNETRIE = /lib/libprunetrie.a
 endif
 
 ifneq "" "$(wildcard /bin/mkdirs)"
@@ -44,9 +44,9 @@ VPATH = $(OFILE_DIR)
 SYMROOT = .
 
 BINDIR = /bin
-USRBINDIR = /usr/bin
-LOCBINDIR = /usr/local/bin
-LOCLIBDIR = /usr/local/lib
+USRBINDIR = /bin
+LOCBINDIR = /bin
+LOCLIBDIR = /lib
 
 CFILES1 = libtool.c
 CFILES2 = lipo.c size.c strings.c nm.c checksyms.c inout.c \
@@ -331,62 +331,62 @@ install: all $(RC_OS)_install
 
 teflon_install macos_install: common_install
 	$(MKDIRS) $(DSTROOT)$(USRBINDIR)
-	install -c -s -m 555 $(SYMROOT)/strip.NEW $(DSTROOT)$(USRBINDIR)/strip
-	install -c -s -m 555 $(SYMROOT)/strings.NEW \
+	install -c -m 555 $(SYMROOT)/strip.NEW $(DSTROOT)$(USRBINDIR)/strip
+	install -c -m 555 $(SYMROOT)/strings.NEW \
 		$(DSTROOT)$(USRBINDIR)/strings
-	install -c -s -m 555 $(SYMROOT)/size.NEW $(DSTROOT)$(USRBINDIR)/size
-	install -c -s -m 555 $(SYMROOT)/nm.NEW $(DSTROOT)$(USRBINDIR)/nm
-	install -c -s -m 555 $(SYMROOT)/libtool.NEW \
+	install -c -m 555 $(SYMROOT)/size.NEW $(DSTROOT)$(USRBINDIR)/size
+	install -c -m 555 $(SYMROOT)/nm.NEW $(DSTROOT)$(USRBINDIR)/nm
+	install -c -m 555 $(SYMROOT)/libtool.NEW \
 		$(DSTROOT)$(USRBINDIR)/libtool
 	(cd $(DSTROOT)$(USRBINDIR); rm -f ranlib; ln -s libtool ranlib)
-	install -c -s -m 555 $(SYMROOT)/lipo.NEW $(DSTROOT)$(USRBINDIR)/lipo
-	install -c -s -m 555 $(SYMROOT)/segedit.NEW \
+	install -c -m 555 $(SYMROOT)/lipo.NEW $(DSTROOT)$(USRBINDIR)/lipo
+	install -c -m 555 $(SYMROOT)/segedit.NEW \
 		$(DSTROOT)$(USRBINDIR)/segedit
-	install -c -s -m 555 $(SYMROOT)/cmpdylib.NEW \
+	install -c -m 555 $(SYMROOT)/cmpdylib.NEW \
 			  $(DSTROOT)$(USRBINDIR)/cmpdylib
-	install -c -s -m 555 $(SYMROOT)/pagestuff.NEW \
+	install -c -m 555 $(SYMROOT)/pagestuff.NEW \
 			  $(DSTROOT)$(USRBINDIR)/pagestuff
-	install -c -s -m 555 $(SYMROOT)/redo_prebinding.NEW \
+	install -c -m 555 $(SYMROOT)/redo_prebinding.NEW \
 			  $(DSTROOT)$(USRBINDIR)/redo_prebinding
-	install -c -s -m 555 $(SYMROOT)/nmedit.NEW $(DSTROOT)$(USRBINDIR)/nmedit
+	install -c -m 555 $(SYMROOT)/nmedit.NEW $(DSTROOT)$(USRBINDIR)/nmedit
 	(cd $(DSTROOT)$(LOCBINDIR); rm -f nmedit; \
 	 ln -s $(USRBINDIR)/nmedit nmedit)
-	install -c -s -m 555 $(SYMROOT)/install_name_tool.NEW \
+	install -c -m 555 $(SYMROOT)/install_name_tool.NEW \
 			  $(DSTROOT)$(USRBINDIR)/install_name_tool
-	install -c -s -m 555 $(SYMROOT)/codesign_allocate.NEW \
+	install -c -m 555 $(SYMROOT)/codesign_allocate.NEW \
 			  $(DSTROOT)$(USRBINDIR)/codesign_allocate
-	install -c -s -m 555 $(SYMROOT)/ctf_insert.NEW \
+	install -c -m 555 $(SYMROOT)/ctf_insert.NEW \
 			  $(DSTROOT)$(USRBINDIR)/ctf_insert
 
 nextstep_install: common_install
 	$(MKDIRS) $(DSTROOT)$(BINDIR)
 	$(MKDIRS) $(DSTROOT)$(LOCBINDIR)
-	install -c -s -m 555 $(SYMROOT)/strip.NEW $(DSTROOT)$(BINDIR)/strip
-	install -c -s -m 555 $(SYMROOT)/strings.NEW $(DSTROOT)$(BINDIR)/strings
-	install -c -s -m 555 $(SYMROOT)/size.NEW $(DSTROOT)$(BINDIR)/size
-	install -c -s -m 555 $(SYMROOT)/nm.NEW $(DSTROOT)$(BINDIR)/nm
-	install -c -s -m 555 $(SYMROOT)/libtool.NEW $(DSTROOT)$(BINDIR)/libtool
+	install -c -m 555 $(SYMROOT)/strip.NEW $(DSTROOT)$(BINDIR)/strip
+	install -c -m 555 $(SYMROOT)/strings.NEW $(DSTROOT)$(BINDIR)/strings
+	install -c -m 555 $(SYMROOT)/size.NEW $(DSTROOT)$(BINDIR)/size
+	install -c -m 555 $(SYMROOT)/nm.NEW $(DSTROOT)$(BINDIR)/nm
+	install -c -m 555 $(SYMROOT)/libtool.NEW $(DSTROOT)$(BINDIR)/libtool
 	(cd $(DSTROOT)$(BINDIR); rm -f ranlib; ln -s libtool ranlib)
-	install -c -s -m 555 $(SYMROOT)/lipo.NEW $(DSTROOT)$(BINDIR)/lipo
-	install -c -s -m 555 $(SYMROOT)/segedit.NEW $(DSTROOT)$(BINDIR)/segedit
-	install -c -s -m 555 $(SYMROOT)/cmpdylib.NEW \
+	install -c -m 555 $(SYMROOT)/lipo.NEW $(DSTROOT)$(BINDIR)/lipo
+	install -c -m 555 $(SYMROOT)/segedit.NEW $(DSTROOT)$(BINDIR)/segedit
+	install -c -m 555 $(SYMROOT)/cmpdylib.NEW \
 		$(DSTROOT)$(BINDIR)/cmpdylib
-	install -c -s -m 555 $(SYMROOT)/pagestuff.NEW \
+	install -c -m 555 $(SYMROOT)/pagestuff.NEW \
 		$(DSTROOT)$(BINDIR)/pagestuff
-	install -c -s -m 555 $(SYMROOT)/redo_prebinding.NEW \
+	install -c -m 555 $(SYMROOT)/redo_prebinding.NEW \
 			  $(DSTROOT)$(BINDIR)/redo_prebinding
-	install -c -s -m 555 $(SYMROOT)/nmedit.NEW $(DSTROOT)$(LOCBINDIR)/nmedit
+	install -c -m 555 $(SYMROOT)/nmedit.NEW $(DSTROOT)$(LOCBINDIR)/nmedit
 
 common_install:
 	$(MKDIRS) $(DSTROOT)$(LOCBINDIR)
-	install -c -s -m 555 $(SYMROOT)/checksyms.NEW \
+	install -c -m 555 $(SYMROOT)/checksyms.NEW \
 			  $(DSTROOT)$(LOCBINDIR)/checksyms
-	install -c -s -m 555 $(SYMROOT)/seg_addr_table.NEW \
+	install -c -m 555 $(SYMROOT)/seg_addr_table.NEW \
 			  $(DSTROOT)$(LOCBINDIR)/seg_addr_table
-	install -c -s -m 555 $(SYMROOT)/check_dylib.NEW \
+	install -c -m 555 $(SYMROOT)/check_dylib.NEW \
 			  $(DSTROOT)$(LOCBINDIR)/check_dylib
-	install -c -s -m 555 $(SYMROOT)/indr.NEW $(DSTROOT)$(LOCBINDIR)/indr
-	install -c -s -m 555 $(SYMROOT)/seg_hack.NEW \
+	install -c -m 555 $(SYMROOT)/indr.NEW $(DSTROOT)$(LOCBINDIR)/indr
+	install -c -m 555 $(SYMROOT)/seg_hack.NEW \
 			  $(DSTROOT)$(LOCBINDIR)/seg_hack
 
 lib_ofiles_install: lib_ofiles
diff --git a/otool/Makefile b/otool/Makefile
index d17d210..a912fb3 100644
--- a/otool/Makefile
+++ b/otool/Makefile
@@ -55,7 +55,7 @@ ifeq "macos" "$(RC_OS)"
   SYSTEMDIR := $(shell if [ "$(RC_RELEASE)" = "Beaker" ] || \
 			  [ "$(RC_RELEASE)" = "Bunsen" ] || \
 			  [ "$(RC_RELEASE)" = "Gonzo" ]; then \
-	 echo /Local/Developer/System; else echo /usr/local/lib/system; fi; )
+	 echo /Local/Developer/System; else echo /lib/system; fi; )
 else
   SYSTEMDIR = /Local/Developer/System
 endif
@@ -94,7 +94,7 @@ OFILE_DIR = $(OBJROOT)
 VPATH = $(OFILE_DIR)
 
 BINDIR = /bin
-USRBINDIR = /usr/bin
+USRBINDIR = /bin
 
 CFILES = main.c ofile_print.c m68k_disasm.c i860_disasm.c \
 	 m88k_disasm.c i386_disasm.c ppc_disasm.c hppa_disasm.c \
@@ -152,12 +152,12 @@ install: all $(RC_OS)_install
 
 teflon_install macos_install:
 	$(MKDIRS) $(DSTROOT)$(USRBINDIR)
-	install -c -s -m 555 $(SYMROOT)/$(PRODUCT).NEW \
+	install -c -m 555 $(SYMROOT)/$(PRODUCT).NEW \
 		$(DSTROOT)$(USRBINDIR)/$(PRODUCT)
 
 nextstep_install:
 	$(MKDIRS) $(DSTROOT)$(BINDIR)
-	install -c -s -m 555 $(SYMROOT)/$(PRODUCT).NEW \
+	install -c -m 555 $(SYMROOT)/$(PRODUCT).NEW \
 		$(DSTROOT)$(BINDIR)/$(PRODUCT)
 
 installsrc:


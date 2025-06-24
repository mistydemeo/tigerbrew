class Lcov < Formula
  desc "Graphical front-end for GCC's coverage testing tool (gcov)"
  homepage "http://ltp.sourceforge.net/coverage/lcov.php"
  url "https://downloads.sourceforge.net/ltp/lcov-1.11.tar.gz"
  sha256 "c282de8d678ecbfda32ce4b5c85fc02f77c2a39a062f068bd8e774d29ddc9bf8"

  head "https://github.com/linux-test-project/lcov.git"


  patch :DATA

  def install
    inreplace %w[bin/genhtml bin/geninfo bin/lcov],
      "/etc/lcovrc", "#{prefix}/etc/lcovrc"
    system "make", "PREFIX=#{prefix}", "install"
  end
end

__END__
--- lcov-1.8/bin/install.sh~	2010-01-29 19:14:46.000000000 +0900
+++ lcov-1.8/bin/install.sh	2010-04-16 21:40:57.000000000 +0900
@@ -34,7 +34,8 @@
   local TARGET=$2
   local PARAMS=$3
 
-  install -p -D $PARAMS $SOURCE $TARGET
+  mkdir -p `dirname $TARGET`
+  install -p $PARAMS $SOURCE $TARGET
 }
 
 
--- lcov-1.8/Makefile~	2010-01-29 19:14:46.000000000 +0900
+++ lcov-1.8/Makefile	2010-04-16 21:42:26.000000000 +0900
@@ -15,8 +15,8 @@
 RELEASE := 1
 
 CFG_DIR := $(PREFIX)/etc
-BIN_DIR := $(PREFIX)/usr/bin
-MAN_DIR := $(PREFIX)/usr/share/man
+BIN_DIR := $(PREFIX)/bin
+MAN_DIR := $(PREFIX)/share/man
 TMP_DIR := /tmp/lcov-tmp.$(shell echo $$$$)
 FILES   := $(wildcard bin/*) $(wildcard man/*) README CHANGES Makefile \
 	   $(wildcard rpm/*) lcovrc

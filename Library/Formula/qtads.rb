class Qtads < Formula
  desc "A cross-platform, multimedia interpreter for TADS games"
  homepage "https://realnc.github.io/qtads/"
  url "https://github.com/realnc/qtads/releases/download/2.1.7/qtads-2.1.7.tar.bz2"
  version "2.1.7"
  sha256 "7477bb3cb1f74dcf7995a25579be8322c13f64fb02b7a6e3b2b95a36276ef231"
  license "GPL-2.0-or-later"

  # Ride the defaults, rather than raising requirements
  # Use SDL rather than SDL2, as we lack SDL2_sound
  # Skip checking for an update on start to avoid being greeted with an error
  # for HTTP 301
  patch :p0, :DATA

  depends_on "qt"
  depends_on "sdl_mixer"
  depends_on "sdl_sound"

  def install
    system "qmake"
    system "make"
    prefix.install "QTads.app"
    man6.install "share/man/man6/qtads.6"
  end

  def caveats
    <<~EOS
    Visit The Interactive Fiction Archive for games
    https://ifarchive.org
    EOS
  end

end
__END__
--- qtads.pro.orig	2026-01-25 14:05:32.000000000 +0000
+++ qtads.pro	2026-01-25 14:27:55.000000000 +0000
@@ -32,11 +32,10 @@
 
 macx {
     QMAKE_INFO_PLIST = Info.plist
-    QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.7
     CONFIG += link_pkgconfig
-    PKGCONFIG += SDL2_mixer
+    PKGCONFIG += SDL_mixer
     LIBS += -lSDL_sound
-    QMAKE_CFLAGS += -std=gnu11 -fvisibility=hidden
+    QMAKE_CFLAGS += -fvisibility=hidden
     QMAKE_CXXFLAGS += -fvisibility=hidden
     QMAKE_LFLAGS += -dead_strip
 } else:!android {
--- src/sysframe.cc.orig	2026-01-25 14:20:43.000000000 +0000
+++ src/sysframe.cc	2026-01-25 14:21:31.000000000 +0000
@@ -365,23 +365,6 @@
     this->fMainWin->resize(this->fSettings->appSize);
     this->fMainWin->show();
 
-    // Do an online update check.
-    int daysRequired;
-    switch (this->fSettings->updateFreq) {
-      case Settings::UpdateOnEveryStart: daysRequired = 0; break;
-      case Settings::UpdateDaily:        daysRequired = 1; break;
-      case Settings::UpdateWeekly:       daysRequired = 7; break;
-      default:                           daysRequired = -1;
-    }
-    if (not this->fSettings->lastUpdateDate.isValid()) {
-        // Force update check.
-        daysRequired = 0;
-    }
-    int daysPassed = this->fSettings->lastUpdateDate.daysTo(QDate::currentDate());
-    if (daysPassed >= daysRequired and daysRequired > -1) {
-        this->fMainWin->checkForUpdates();
-    }
-
     // If a game file was specified, try to run it.
     if (not gameFileName.isEmpty()) {
         this->setNextGame(gameFileName);

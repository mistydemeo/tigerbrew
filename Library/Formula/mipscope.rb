class Mipscope < Formula
  desc "A cross-platform IDE for students learning assembly on the MIPS architecture"
  homepage "http://mipscope.cs.brown.edu"
  url "http://mipscope.cs.brown.edu/downloads/mipscope-0.3.3.tar.gz"
  version "0.3.3"
  sha256 "52df7c7a9eb71f89cbb57f761ed757a8d2712759219f3a896bddc12258c74607"

  # Allow building on systems older than 10.6
  patch :p0, :DATA

  depends_on "qt"

  def install
    system "qmake", "mipscope.pro"
    system "make"
    prefix.install Dir['mipscope.app']
    pkgshare.install "src/test.s"
    pkgshare.install "src/tester"
  end

  def caveats; <<-EOS.undent
      For example files to load on to the simulator see
      #{pkgshare}
    EOS
  end
end
__END__
--- mipscope.pro.orig	2024-05-08 00:37:34.000000000 +0100
+++ mipscope.pro	2024-05-08 00:37:40.000000000 +0100
@@ -145,10 +145,3 @@
              src/gui/plugins/maze/images/mazeImages.qrc
 OBJECTS_DIR = obj
 MOC_DIR     = obj
-
-macx {
-	QMAKE_MAC_SDK                  = /Developer/SDKs/MacOSX10.6.sdk
-	QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.5
-	QMAKE_CXX                      = g++-4.2
-	CONFIG                        += x86 x86_64
-}
--- src/gui/Gui.cpp.orig	2024-05-11 20:21:30.000000000 +0100
+++ src/gui/Gui.cpp	2024-05-11 20:17:09.000000000 +0100
@@ -50,6 +50,7 @@
 #include "../simulator/Statement.H"
 #include <QtGui>
 #include <QProcess>
+#include <unistd.h>
 
 Gui::Gui(QStringList args) : QMainWindow(), 
    m_options(new Options(this)), 
--- src/gui/plugins/maze/MazePlugin.cpp.orig	2024-05-11 20:20:06.000000000 +0100
+++ src/gui/plugins/maze/MazePlugin.cpp	2024-05-11 20:20:25.000000000 +0100
@@ -40,6 +40,7 @@
 #include "MazeUi.H"
 #include <QtGui>
 #include <sstream>
+#include <unistd.h>
 
 #ifdef Q_OS_WIN32
 // For Sleep()

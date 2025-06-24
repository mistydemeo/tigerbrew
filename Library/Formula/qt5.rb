class OracleHomeVarRequirement < Requirement
  fatal true
  satisfy(:build_env => false) { ENV["ORACLE_HOME"] }

  def message; <<-EOS.undent
      To use --with-oci you have to set the ORACLE_HOME environment variable.
      Check Oracle Instant Client documentation for more information.
    EOS
  end
end

# Patches for Qt5 must be at the very least submitted to Qt's Gerrit codereview
# rather than their bug-report Jira. The latter is rarely reviewed by Qt.
class Qt5 < Formula
  desc "Version 5 of the Qt framework"
  homepage "https://www.qt.io/"
  head "https://code.qt.io/qt/qt5.git", :branch => "5.5", :shallow => false
  revision 1

  stable do
    url "https://download.qt.io/official_releases/qt/5.5/5.5.0/single/qt-everywhere-opensource-src-5.5.0.tar.xz"
    mirror "https://www.mirrorservice.org/sites/download.qt-project.org/official_releases/qt/5.5/5.5.0/single/qt-everywhere-opensource-src-5.5.0.tar.xz"
    sha256 "7ea2a16ecb8088e67db86b0835b887d5316121aeef9565d5d19be3d539a2c2af"

    # Apple's 3.6.0svn based clang doesn't support -Winconsistent-missing-override
    # https://bugreports.qt.io/browse/QTBUG-46833
    # This is fixed in 5.5 branch and below patch should be removed
    # when this formula is updated to 5.5.1
    patch :DATA

    # Build error: Fix build with clang 3.7.
    # https://codereview.qt-project.org/#/c/121545/
    # Should land in the 5.5.1 release.
    patch do
      url "https://raw.githubusercontent.com/DomT4/scripts/2107043e8/Homebrew_Resources/Qt5/qt5_el_capitan.diff"
      sha256 "bd8fd054247ec730f60778e210d58cba613265e5df04ec93f4110421fb03b14a"
    end

    # Build error: Fix library paths with Xcode 7 for QtWebEngine.
    # https://codereview.qt-project.org/#/c/122729/
    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/2fcc1f8ec1df1c90785f4fa6632cebac68772fa9/qt5/el-capitan-2.diff"
      sha256 "b8f04efd047eeed7cfd15b029ece20b5fe3c0960b74f7a5cb98bd36475463227"
    end

    # Build error: Fix CGEventCreateMouseEvent use with 10.11 SDK.
    # https://codereview.qt-project.org/#/c/115138/
    # Should land in the 5.5.1 release.
    patch do
      url "https://gist.githubusercontent.com/UniqMartin/baf089e326f572150971/raw/1de52d53929bc3472cc7f345c16f068c37c75263/qtbug-47641.patch"
      sha256 "c74c73b2d540788f0be2f1f137d0844feca8f5022a044851366380bf2972ead0"
    end

    # Runtime error: Make tooltips transparent for mouse events.
    # https://codereview.qt-project.org/#/c/124274/
    # Should land in the 5.5.1 release.
    patch do
      url "https://gist.githubusercontent.com/swallat/6b7d10fd929a0087fea4/raw/9b201a2848f8b8e16067855f30588a7b6dc607ec/qt5.5-qnsview-tooltip-cocoa.patch"
      sha256 "5fa4511ee0c91491358d569f884dad9e4088eafa329e7dbe2b38a62afeef899d"
    end

    # Fix for qmake producing broken pkg-config files, affecting Poppler et al.
    # https://codereview.qt-project.org/#/c/126584/
    # Should land in the 5.5.2 and/or 5.6 release.
    patch do
      url "https://gist.githubusercontent.com/UniqMartin/a54542d666be1983dc83/raw/f235dfb418c3d0d086c3baae520d538bae0b1c70/qtbug-47162.patch"
      sha256 "e31df5d0c5f8a9e738823299cb6ed5f5951314a28d4a4f9f021f423963038432"
    end
  end


  keg_only "Qt 5 conflicts Qt 4 (which is currently much more widely used)."

  option :universal
  option "with-docs", "Build documentation"
  option "with-examples", "Build examples"
  option "with-developer", "Build and link with developer options"
  option "with-oci", "Build with Oracle OCI plugin"

  deprecated_option "developer" => "with-developer"
  deprecated_option "qtdbus" => "with-d-bus"

  # Snow Leopard is untested and support has been removed in 5.4
  # https://qt.gitorious.org/qt/qtbase/commit/5be81925d7be19dd0f1022c3cfaa9c88624b1f08
  depends_on :macos => :lion
  depends_on "pkg-config" => :build
  depends_on "d-bus" => :optional
  depends_on :mysql => :optional
  depends_on :xcode => :build

  depends_on OracleHomeVarRequirement if build.with? "oci"

  def install
    ENV.universal_binary if build.universal?

    args = ["-prefix", prefix,
            "-system-zlib", "-securetransport",
            "-qt-libpng", "-qt-libjpeg",
            "-no-rpath", "-no-openssl",
            "-confirm-license", "-opensource",
            "-nomake", "tests", "-release"]

    args << "-nomake" << "examples" if build.without? "examples"

    args << "-plugin-sql-mysql" if build.with? "mysql"

    if build.with? "d-bus"
      dbus_opt = Formula["d-bus"].opt_prefix
      args << "-I#{dbus_opt}/lib/dbus-1.0/include"
      args << "-I#{dbus_opt}/include/dbus-1.0"
      args << "-L#{dbus_opt}/lib"
      args << "-ldbus-1"
      args << "-dbus-linked"
    end

    if MacOS.prefer_64_bit? || build.universal?
      args << "-arch" << "x86_64"
    end

    if !MacOS.prefer_64_bit? || build.universal?
      args << "-arch" << "x86"
    end

    if build.with? "oci"
      args << "-I#{ENV["ORACLE_HOME"]}/sdk/include"
      args << "-L#{ENV["ORACLE_HOME"]}"
      args << "-plugin-sql-oci"
    end

    args << "-developer-build" if build.with? "developer"

    system "./configure", *args
    system "make"
    ENV.j1
    system "make", "install"

    if build.with? "docs"
      system "make", "docs"
      system "make", "install_docs"
    end

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # configure saved PKG_CONFIG_LIBDIR set up by superenv; remove it
    # see: https://github.com/Homebrew/homebrew/issues/27184
    inreplace prefix/"mkspecs/qconfig.pri", /\n\n# pkgconfig/, ""
    inreplace prefix/"mkspecs/qconfig.pri", /\nPKG_CONFIG_.*=.*$/, ""

    Pathname.glob("#{bin}/*.app") { |app| mv app, prefix }
  end

  def caveats; <<-EOS.undent
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.
    EOS
  end

  test do
    (testpath/"hello.pro").write <<-EOS.undent
      QT       += core
      QT       -= gui
      TARGET = hello
      CONFIG   += console
      CONFIG   -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    EOS

    (testpath/"main.cpp").write <<-EOS.undent
      #include <QCoreApplication>
      #include <QDebug>

      int main(int argc, char *argv[])
      {
        QCoreApplication a(argc, argv);
        qDebug() << "Hello World!";
        return 0;
      }
    EOS

    system bin/"qmake", testpath/"hello.pro"
    system "make"
    assert File.exist?("hello")
    assert File.exist?("main.o")
    system "./hello"
  end
end

__END__
diff --git a/qtbase/src/corelib/global/qcompilerdetection.h b/qtbase/src/corelib/global/qcompilerdetection.h
index 7ff1b67..060af29 100644
--- a/qtbase/src/corelib/global/qcompilerdetection.h
+++ b/qtbase/src/corelib/global/qcompilerdetection.h
@@ -155,7 +155,7 @@
 /* Clang also masquerades as GCC */
 #    if defined(__apple_build_version__)
 #      /* http://en.wikipedia.org/wiki/Xcode#Toolchain_Versions */
-#      if __apple_build_version__ >= 6020049
+#      if __apple_build_version__ >= 7000053
 #        define Q_CC_CLANG 306
 #      elif __apple_build_version__ >= 6000051
 #        define Q_CC_CLANG 305

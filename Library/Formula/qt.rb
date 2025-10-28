class Qt < Formula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"

  stable do
    url "https://download.qt.io/archive/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz"
    sha256 "e2882295097e47fe089f8ac741a95fef47e0a73a3f3cdf21b56990638f626ea0"
  end

  bottle do
    sha256 "94b2e34789e760c428b0d43a04b723dcd34be4fc4e2f17fd73352470bbc9ecb0" => :tiger_altivec
    sha256 "f677f0739ddd06b0a8f1307ab7e373fb77bce49c0dbc6f0978282546edadc5db" => :leopard_g3
    sha256 "392df462ad214256145f95a627a62e35d17cd765bac92526977890c378a6afe9" => :leopard_altivec
  end

  # Backport of Qt5 commit to fix the fatal build error on OS X El Capitan.
  # http://code.qt.io/cgit/qt/qtbase.git/commit/?id=b06304e164ba47351fa292662c1e6383c081b5ca
  if MacOS.version >= :el_capitan
    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/480b7142c4e2ae07de6028f672695eb927a34875/qt/el-capitan.patch"
      sha256 "c8a0fa819c8012a7cb70e902abb7133fc05235881ce230235d93719c47650c4e"
    end
  end

  # Fixes build on 10.5 - "‘kCFURLIsHiddenKey’ was not declared in this scope"
  # https://github.com/mistydemeo/tigerbrew/issues/303
  # Support OpenSSL 1.1.1 - TODO
  # https://github.com/macports/macports-ports/blob/master/aqua/qt4-mac/files/patch-qt4-openssl111.diff
  # Fix build on macOS 10.4 and 10.5 - missing patch to qpaintengine_mac.cpp because it doesn't apply
  # https://github.com/cartr/homebrew-qt4/pull/35/files
  # UF_HIDDEN shows up in Leopard, confine to Cocoa builds.
  # QtHelp needs to link against libQtCLucene. 
  patch :p0, :DATA

  option :universal
  option "with-docs", "Build documentation"
  option "with-developer", "Build and link with developer options"

  depends_on "d-bus" => :optional
  depends_on "mysql" => :optional
  depends_on "postgresql" => :optional
  depends_on "pkg-config" => :build
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "sqlite"
  depends_on "zlib"

  deprecated_option "qtdbus" => "with-d-bus"
  deprecated_option "developer" => "with-developer"

  # Build error on Tiger with GCC 4.2 but not 4.0
  # In file included from /System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/Header
  # s/DriverServices.h:32,
  #                  from /System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/Header
  # s/CarbonCore.h:125,
  #                  from /System/Library/Frameworks/CoreServices.framework/Headers/CoreServices.h:21,
  #                  from /System/Library/Frameworks/ApplicationServices.framework/Headers/ApplicationServices.h:2
  # 0,
  #                  from generators/mac/pbuilder_pbx.cpp:56:
  # /System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/Headers/MachineExceptions.h:
  # 115: error: expected ‘;’ before ‘unsigned’
  fails_with :gcc if MacOS.version < :leopard

  def install
    ENV.universal_binary if build.universal?
    # Build itself sets -O2
    ENV.no_optimization

    args = %W[
      -prefix #{prefix}
      -plugindir #{prefix}/lib/qt4/plugins
      -importdir #{prefix}/lib/qt4/imports
      -datadir #{prefix}/etc/qt4
      -release
      -opensource
      -confirm-license
      -fast
      -system-zlib
      -qt-libtiff
      -qt-libpng
      -qt-libjpeg
      -nomake demos
      -nomake examples
      -no-webkit
      -plugin-sql-sqlite
    ]

    if ENV.compiler == :clang
      args << "-platform"

      if MacOS.version >= :mavericks
        args << "unsupported/macx-clang-libc++"
      else
        args << "unsupported/macx-clang"
      end
    end

    # Tiger is supported with the Carbon build. Cocoa build needs Leopard.
    if MacOS.version < :leopard
      args << "-carbon"
    else
      args << "-cocoa"
    end

    args << "-plugin-sql-mysql" if build.with? "mysql"
    args << "-plugin-sql-psql" if build.with? "postgresql"

    if build.with? "d-bus"
      dbus_opt = Formula["d-bus"].opt_prefix
      args << "-I#{dbus_opt}/lib/dbus-1.0/include"
      args << "-I#{dbus_opt}/include/dbus-1.0"
      args << "-L#{dbus_opt}/lib"
      args << "-ldbus-1"
      args << "-dbus-linked"
    end

    args << "-nomake" << "docs" if build.without? "docs"

    if Hardware.cpu_type != :ppc
      if MacOS.prefer_64_bit? || build.universal?
        args << "-arch" << "x86_64"
      end

      if !MacOS.prefer_64_bit? || build.universal?
        args << "-arch" << "x86"
      end
    else
      if MacOS.prefer_64_bit? or build.universal?
        args << "-arch" << "ppc64"
      end

      if !MacOS.prefer_64_bit? or build.universal?
        args << "-arch" << "ppc"
      end
    end

    args << "-developer-build" if build.with? "developer"

    system "./configure", *args
    system "make"
    ENV.j1
    system "make", "install"

    # what are these anyway?
    (bin+"pixeltool.app").rmtree
    (bin+"qhelpconverter.app").rmtree

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    Pathname.glob("#{bin}/*.app") { |app| mv app, prefix }
  end

  test do
    system "#{bin}/qmake", "-project"
  end

  def caveats; <<-EOS.undent
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.
    EOS
  end
end

__END__
diff --git a/src/gui/dialogs/qfiledialog_mac.mm b/src/gui/dialogs/qfiledialog_mac.mm
index c51f6ad..f4bd8b8 100644
--- src/gui/dialogs/qfiledialog_mac.mm
+++ src/gui/dialogs/qfiledialog_mac.mm
@@ -297,6 +297,7 @@ QT_USE_NAMESPACE
     CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filename, kCFURLPOSIXPathStyle, isDir);
     CFBooleanRef isHidden;
     Boolean errorOrHidden = false;
+#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6
     if (!CFURLCopyResourcePropertyForKey(url, kCFURLIsHiddenKey, &isHidden, NULL)) {
         errorOrHidden = true;
     } else {
@@ -304,6 +305,7 @@ QT_USE_NAMESPACE
             errorOrHidden = true;
         CFRelease(isHidden);
     }
+#endif
     CFRelease(url);
     return errorOrHidden;
 #else
--- src/corelib/io/qfilesystemengine_unix.cpp.orig	2017-08-31 20:54:04.000000000 +0200
+++ src/corelib/io/qfilesystemengine_unix.cpp	2017-08-31 20:58:13.000000000 +0200
@@ -83,6 +83,7 @@
     return (fileInfo->finderFlags & kIsInvisible);
 }
 
+#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
 static bool isPackage(const QFileSystemMetaData &data, const QFileSystemEntry &entry)
 {
     if (!data.isDirectory())
@@ -138,6 +139,7 @@
     FolderInfo *folderInfo = reinterpret_cast<FolderInfo *>(catalogInfo.finderInfo);
     return folderInfo->finderFlags & kHasBundle;
 }
+#endif
 
 #else
 static inline bool _q_isMacHidden(const char *nativePath)
@@ -529,8 +531,22 @@
 
 #if !defined(QWS) && !defined(Q_WS_QPA) && defined(Q_OS_MAC)
     if (what & QFileSystemMetaData::BundleType) {
+#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
         if (entryExists && isPackage(data, entry))
             data.entryFlags |= QFileSystemMetaData::BundleType;
+#else
+        if (entryExists && data.isDirectory()) {
+            QCFType<CFStringRef> path = CFStringCreateWithBytes(0,
+                    (const UInt8*)nativeFilePath, nativeFilePathLength,
+                    kCFStringEncodingUTF8, false);
+            QCFType<CFURLRef> url = CFURLCreateWithFileSystemPath(0, path,
+                    kCFURLPOSIXPathStyle, true);
+
+            UInt32 type, creator;
+            if (CFBundleGetPackageInfoInDirectory(url, &type, &creator))
+                data.entryFlags |= QFileSystemMetaData::BundleType;
+        }
+#endif
         data.knownFlagsMask |= QFileSystemMetaData::BundleType;
     }
 #endif
--- src/gui/dialogs/qfontdialog_mac.mm.orig	2017-08-31 21:41:56.000000000 +0200
+++ src/gui/dialogs/qfontdialog_mac.mm	2017-08-31 21:55:51.000000000 +0200
@@ -141,6 +141,7 @@
     QFont newFont;
     if (cocoaFont) {
         int pSize = qRound([cocoaFont pointSize]);
+#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
         CTFontDescriptorRef font = CTFontCopyFontDescriptor((CTFontRef)cocoaFont);
         // QCoreTextFontDatabase::populateFontDatabase() is using localized names
         QString family = QCFString::toQString((CFStringRef) CTFontDescriptorCopyLocalizedAttribute(font, kCTFontFamilyNameAttribute, NULL));
@@ -151,6 +152,23 @@
         newFont.setStrikeOut(resolveFont.strikeOut());
 
         CFRelease(font);
+#else
+	// This pre-Leopard version is buggy and was fixed in 717e36037cf246aa201c0aaf15a5dcbd7883f159
+	// see QTBUG-27415 https://codereview.qt-project.org/#/c/42830/
+        QString family(qt_mac_NSStringToQString([cocoaFont familyName]));
+        QString typeface(qt_mac_NSStringToQString([cocoaFont fontName]));
+
+        int hyphenPos = typeface.indexOf(QLatin1Char('-'));
+        if (hyphenPos != -1) {
+            typeface.remove(0, hyphenPos + 1);
+        } else {
+            typeface = QLatin1String("Normal");
+        }
+
+        newFont = QFontDatabase().font(family, typeface, pSize);
+        newFont.setUnderline(resolveFont.underline());
+        newFont.setStrikeOut(resolveFont.strikeOut());
+#endif
     }
     return newFont;
 }
--- src/gui/painting/qprintengine_mac.mm.orig	2017-08-31 21:35:19.000000000 +0200
+++ src/gui/painting/qprintengine_mac.mm	2017-08-31 21:37:56.000000000 +0200
@@ -187,7 +187,11 @@
             paperMargins.top = topMargin;
             paperMargins.right = rightMargin;
             paperMargins.bottom = bottomMargin;
+#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
             PMPaperCreateCustom(printer, paperId, QCFString("Custom size"), customSize.width(), customSize.height(), &paperMargins, &customPaper);
+#else
+            PMPaperCreate(printer, paperId, QCFString("Custom size"), customSize.width(), customSize.height(), &paperMargins, &customPaper);
+#endif
             PMPageFormat tmp;
             PMCreatePageFormatWithPMPaper(&tmp, customPaper);
             PMCopyPageFormat(tmp, format);
--- src/gui/text/qfontdatabase_mac.cpp.orig	2017-08-31 22:45:17.000000000 +0200
+++ src/gui/text/qfontdatabase_mac.cpp	2017-08-31 23:10:46.000000000 +0200
@@ -546,6 +546,7 @@
 
 QString QFontDatabase::resolveFontFamilyAlias(const QString &family)
 {
+#if defined(QT_MAC_USE_COCOA) && (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
     QCFString expectedFamily = QCFString(family);
 
     QCFType<CFMutableDictionaryRef> attributes = CFDictionaryCreateMutable(NULL, 0,
@@ -563,6 +564,10 @@
 
     QCFString familyName = (CFStringRef) CTFontDescriptorCopyLocalizedAttribute(matched, kCTFontFamilyNameAttribute, NULL);
     return familyName;
+#else
+    // https://bugreports.qt.io/browse/QTBUG-25417?focusedCommentId=185393&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-185393
+    return family;
+#endif
 }
 
 QT_END_NAMESPACE
--- src/network/kernel/qnetworkproxy_mac.cpp.orig	2017-08-31 21:05:13.000000000 +0200
+++ src/network/kernel/qnetworkproxy_mac.cpp	2017-08-31 21:05:44.000000000 +0200
@@ -148,6 +148,7 @@
 }
 
 
+#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
 static QNetworkProxy proxyFromDictionary(CFDictionaryRef dict)
 {
     QNetworkProxy::ProxyType proxyType = QNetworkProxy::DefaultProxy;
@@ -180,6 +181,7 @@
 
     return QNetworkProxy(proxyType, hostName, port, user, password);
 }
+#endif
 
 const char * cfurlErrorDescription(SInt32 errorCode)
 {
--- src/corelib/io/qfilesystemengine.cpp.orig	2024-05-10 22:31:54.000000000 +0100
+++ src/corelib/io/qfilesystemengine.cpp	2024-05-10 22:33:02.000000000 +0100
@@ -281,7 +281,7 @@
     entryFlags |= QFileSystemMetaData::ExistsAttribute;
     size_ = statBuffer.st_size;
 #if !defined(QWS) && !defined(Q_WS_QPA) && defined(Q_OS_MAC) \
-        && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
+        && defined(QT_MAC_USE_COCOA) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
     if (statBuffer.st_flags & UF_HIDDEN) {
         entryFlags |= QFileSystemMetaData::HiddenAttribute;
         knownFlagsMask |= QFileSystemMetaData::HiddenAttribute;
--- tools/assistant/tools/assistant/assistant.pro.orig	2024-05-07 16:20:22.000000000 +0100
+++ tools/assistant/tools/assistant/assistant.pro	2024-05-07 16:21:17.000000000 +0100
@@ -111,6 +111,7 @@
     ICON = assistant.icns
     TARGET = Assistant
     QMAKE_INFO_PLIST = Info_mac.plist
+    LIBS += -lQtCLucene
 }
 
 contains(CONFIG, static): {
--- tools/assistant/tools/qhelpgenerator/qhelpgenerator.pro.orig	2024-05-07 16:38:33.000000000 +0100
+++ tools/assistant/tools/qhelpgenerator/qhelpgenerator.pro	2024-05-07 17:06:39.000000000 +0100
@@ -17,3 +17,4 @@
            main.cpp
 
 HEADERS += ../shared/helpgenerator.h
+LIBS += -lQtCLucene
--- tools/assistant/tools/qcollectiongenerator/qcollectiongenerator.pro.orig	2024-05-07 17:09:42.000000000 +0100
+++ tools/assistant/tools/qcollectiongenerator/qcollectiongenerator.pro	2024-05-07 17:10:22.000000000 +0100
@@ -19,3 +19,4 @@
     ../shared/collectionconfiguration.cpp
 HEADERS += ../shared/helpgenerator.h \
     ../shared/collectionconfiguration.h
+LIBS += -lQtCLucene
--- tools/assistant/tools/qhelpconverter/qhelpconverter.pro.orig	2024-05-07 17:12:03.000000000 +0100
+++ tools/assistant/tools/qhelpconverter/qhelpconverter.pro	2024-05-07 17:12:38.000000000 +0100
@@ -40,6 +40,8 @@
            qhpwriter.h \
            helpwindow.h
 
+LIBS += -lQtCLucene
+
 FORMS   += inputpage.ui \
            generalpage.ui \
            filterpage.ui \

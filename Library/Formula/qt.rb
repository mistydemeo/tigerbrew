class Qt < Formula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"

  stable do
    url "https://download.qt.io/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz"
    mirror "https://www.mirrorservice.org/sites/download.qt-project.org/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz"
    sha256 "e2882295097e47fe089f8ac741a95fef47e0a73a3f3cdf21b56990638f626ea0"
  end

  bottle do
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

  # Makes the MACOSX_DEPLOYMENT_TARGET configurable
  patch :p0 do
    url "https://raw.githubusercontent.com/macports/macports-ports/master/aqua/qt4-mac/files/patch-configure.diff"
    sha256 "b5001ee9df42d77d22b32624c80af37205be4783a964ccfe26f4f754ee7a2dbe"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/macports/macports-ports/master/aqua/qt4-mac/files/patch-mkspecs_common_g%2B%2B-base.conf.diff"
    sha256 "cd023a7a300d9d2a993e707e0374fb944a45e49fe8e50834b157ee330c9901f0"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/macports/macports-ports/master/aqua/qt4-mac/files/patch-mkspecs_common_g++-macx.conf.diff"
    sha256 "e356c4cac6675bd6c2e6886ccbbcb3c4fde5ef7b643446d6239712e3606b6767"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/macports/macports-ports/master/aqua/qt4-mac/files/patch-mkspecs_common_mac.conf.diff"
    sha256 "b720ade0ec31a6140ad0261427930eeb50cd81ca1bde79c65e1b93017c1137f6"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/macports/macports-ports/master/aqua/qt4-mac/files/patch-qmake_qmake.pri.diff"
    sha256 "13a13af4bc4eccb64ff866a7cbc28e8deb40672206727e4d9e47e8539da73afa"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/macports/macports-ports/master/aqua/qt4-mac/files/patch-src_tools_bootstrap_bootstrap.pro.diff"
    sha256 "d2ff4397112215be80abc096937db89da8ba710b69499b169f5870c0fc49c46b"
  end

  if MacOS.version < :leopard
    patch :p0 do
      url "https://raw.githubusercontent.com/macports/macports-ports/bc7db7bdadf141040ffa35fe6308b5039f74c7e0/aqua/qt4-mac/files/patch-src_corelib_io_qfilesystemengine_unix.cpp-tiger.diff"
      sha256 "35377ba0171e71c964bb896a756719fa733a6e48aba2ec19839cae585dea2f71"
    end

    patch :p0 do
      url "https://raw.githubusercontent.com/macports/macports-ports/bc7db7bdadf141040ffa35fe6308b5039f74c7e0/aqua/qt4-mac/files/patch-src_network_kernel_qnetworkproxy_mac.cpp-tiger.diff"
      sha256 "223d116eb6ed6905bb815ce3df2b984cfd405e46bda6ed889393481beabd133f"
    end

    patch :p0 do
      url "https://raw.githubusercontent.com/macports/macports-ports/bc7db7bdadf141040ffa35fe6308b5039f74c7e0/aqua/qt4-mac/files/patch-src_gui_painting_qprintengine_mac.mm-tiger.diff"
      sha256 "bce916ed9643fdb8b674721bd774c576fd7504a7fb900c77a35fc86596541d28"
    end

    patch :p0 do
      url "https://raw.githubusercontent.com/macports/macports-ports/bc7db7bdadf141040ffa35fe6308b5039f74c7e0/aqua/qt4-mac/files/patch-src_gui_dialogs_qfontdialog_mac.mm-tiger.diff"
      sha256 "0719eef855969e3b728cd060683656e90db02cfdeba9c2b763f3ce78c868df71"
    end

    patch :p0 do
      url "https://raw.githubusercontent.com/macports/macports-ports/bc7db7bdadf141040ffa35fe6308b5039f74c7e0/aqua/qt4-mac/files/patch-src_gui_text_qfontdatabase_mac.cpp-tiger.diff"
      sha256 "b5014c18bfd703b37d4dd20e27f7e6f1715626d63eb788a7c64eef6cd1c2019a"
    end

    patch :p0 do
      url "https://raw.githubusercontent.com/macports/macports-ports/master/aqua/qt4-mac/files/patch-src_gui_painting_qpaintengine_mac.diff"
      sha256 "d375639801da219c26bf3ae8a371eefe9321b253915ab8afe765ad3ed98e45d9"
    end

    patch :p0 do
      url "https://raw.githubusercontent.com/macports/macports-ports/bc7db7bdadf141040ffa35fe6308b5039f74c7e0/aqua/qt4-mac/files/patch-src_gui_painting_qpaintengine_mac.cpp-tiger.diff"
      sha256 "a7c0322e898c91ae9cdc5f889dfb0d87265e0623d2533dcf51c09bb733f6aeb2"
    end
  end

  head "https://code.qt.io/qt/qt.git", :branch => "4.8"

  # Fixes build on 10.5 - "‘kCFURLIsHiddenKey’ was not declared in this scope"
  # https://github.com/mistydemeo/tigerbrew/issues/303
  patch :DATA

  option :universal
  option "with-qt3support", "Build with deprecated Qt3Support module support"
  option "with-docs", "Build documentation"
  option "with-developer", "Build and link with developer options"

  depends_on "d-bus" => :optional
  depends_on "mysql" => :optional
  depends_on "postgresql" => :optional

  deprecated_option "qtdbus" => "with-d-bus"
  deprecated_option "developer" => "with-developer"

  def install
    ENV.universal_binary if build.universal?

    inreplace ["configure", "mkspecs/common/g++-macx.conf",
               "mkspecs/common/mac.conf", "qmake/qmake.pri",
               "src/tools/bootstrap/bootstrap.pro"],
              "@MACOSX_DEPLOYMENT_TARGET@",
              MacOS.version.to_s

    inreplace "configure" do |s|
      s.gsub! /EXTRA_CFLAGS=$/, "EXTRA_CFLAGS=#{ENV.cflags}"
      arch = Hardware::CPU.bits == 32 ? Hardware::CPU.arch_32_bit : Hardware::CPU.arch_64_bit
      s.gsub! "@ARCHES@", arch.to_s
    end

    inreplace "mkspecs/common/g++-base.conf" do |s|
      s.gsub! "@CC@", ENV.cc
      s.gsub! "@CXX@", ENV.cxx
    end

    args = ["-prefix", prefix,
            "-system-zlib",
            "-qt-libtiff", "-qt-libpng", "-qt-libjpeg",
            "-confirm-license", "-opensource",
            "-nomake", "demos", "-nomake", "examples",
            "-fast", "-release"]

    # Cocoa build requires 10.5 or newer
    if MacOS.version < :leopard
      args << "-carbon"
    else
      args << "-cocoa"
    end

    if ENV.compiler == :clang
      args << "-platform"

      if MacOS.version >= :mavericks
        args << "unsupported/macx-clang-libc++"
      else
        args << "unsupported/macx-clang"
      end
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

    if build.with? "qt3support"
      args << "-qt3support"
    else
      args << "-no-qt3support"
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
    # remove porting file for non-humans
    (prefix+"q3porting.xml").unlink if build.without? "qt3support"

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
--- a/src/gui/dialogs/qfiledialog_mac.mm
+++ b/src/gui/dialogs/qfiledialog_mac.mm
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

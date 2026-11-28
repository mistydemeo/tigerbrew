class Pyqt < Formula
  desc "Python bindings for Qt"
  homepage "http://www.riverbankcomputing.co.uk/software/pyqt"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt4/4.12.3/PyQt4_gpl_mac-4.12.3.tar.gz"
  sha256 "293e4be7dd741db72b1265e062ea14332ba5532741314f64eb935d141570305f"

  bottle do
  end

  # sip: Deprecation warning: the -B flag is deprecated
  # Error: Unable to create the C++ code.
  patch :p0, :DATA

  option "without-python", "Build without python2 support"
  depends_on :python => :recommended
  depends_on :python3 => :recommended

  if build.without?("python3") && build.without?("python")
    odie "pyqt: --with-python3 must be specified when using --without-python"
  end

  depends_on "qt"

  if build.with? "python3"
    depends_on "sip" => "with-python3"
  else
    depends_on "sip"
  end

  def install
    # On Mavericks we want to target libc++, this requires a non default qt makespec
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      ENV.append "QMAKESPEC", "unsupported/macx-clang-libc++"
    end

    Language::Python.each_python(build) do |python, version|
      ENV.append_path "PYTHONPATH", "#{Formula["sip"].opt_lib}/python#{version}/site-packages"

      args = ["--confirm-license",
              "--bindir=#{bin}",
              "--destdir=#{lib}/python#{version}/site-packages",
              "--sipdir=#{share}/sip"]

      # We need to run "configure.py" so that pyqtconfig.py is generated, which
      # is needed by QGIS, PyQWT (and many other PyQt interoperable
      # implementations such as the ROS GUI libs). This file is currently needed
      # for generating build files appropriate for the qmake spec that was used
      # to build Qt.  The alternatives provided by configure-ng.py is not
      # sufficient to replace pyqtconfig.py yet (see
      # https://github.com/qgis/QGIS/pull/1508). Using configure.py is
      # deprecated and will be removed with SIP v5, so we do the actual compile
      # using the newer configure-ng.py as recommended. In order not to
      # interfere with the build using configure-ng.py, we run configure.py in a
      # temporary directory and only retain the pyqtconfig.py from that.

      require "tmpdir"
      dir = Dir.mktmpdir
      begin
        cp_r(Dir.glob("*"), dir)
        cd dir do
          system python, "configure.py", *args
          inreplace "pyqtconfig.py", Formula["qt"].prefix, Formula["qt"].opt_prefix
          (lib/"python#{version}/site-packages/PyQt4").install "pyqtconfig.py"
        end
      ensure
        remove_entry_secure dir
      end

      # On Mavericks we want to target libc++, this requires a non default qt makespec
      if ENV.compiler == :clang && MacOS.version >= :mavericks
        args << "--spec" << "unsupported/macx-clang-libc++"
      end

      system python, "configure-ng.py", *args
      system "make"
      system "make", "install"
      system "make", "clean"  # for when building against multiple Pythons
    end
  end

  def caveats
    "Phonon support is broken."
  end

  test do
    Pathname("test.py").write <<-EOS.undent
      from PyQt4 import QtNetwork
      QtNetwork.QNetworkAccessManager().networkAccessible()
    EOS

    Language::Python.each_python(build) do |python, _version|
      system python, "test.py"
    end
  end
end
__END__
--- configure-ng.py.orig	2018-08-31 08:40:05.000000000 +0100
+++ configure-ng.py	2025-02-06 11:44:40.000000000 +0000
@@ -2220,8 +2220,8 @@
     argv = [quote(target_config.sip), '-w', '-n', 'PyQt4.sip', '-f', sip_flags]
 
     # Make sure any unknown Qt version gets treated as the latest Qt v4.
-    argv.append('-B')
-    argv.append('Qt_5_0_0')
+    # argv.append('-B')
+    # argv.append('Qt_5_0_0')
 
     if no_timestamp:
         argv.append('-T')

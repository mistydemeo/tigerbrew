class Python3 < Formula
  desc "Interpreted, interactive, object-oriented programming language"
  homepage "https://www.python.org/"
  url "https://www.python.org/ftp/python/3.10.14/Python-3.10.14.tar.xz"
  sha256 "9c50481faa8c2832329ba0fc8868d0a606a680fc4f60ec48d26ce8e076751fda"

  bottle do
    sha256 "eaebc29ef8cd0b64b4032694e68c7f8b95352cc790f457c9fd5a3d4bb76f93ab" => :tiger_altivec
  end

  option :universal

  depends_on "pkg-config" => :build
  depends_on "readline" => :recommended
  depends_on "sqlite"
  depends_on "gdbm" => :recommended
  depends_on "openssl3"
  depends_on "bzip2"
  depends_on "xz" => :recommended # for the lzma module added in 3.3
  depends_on "tcl-tk"
  depends_on :x11 if Tab.for_name("tcl-tk").with?("x11")

  skip_clean "bin/pip3", "bin/pip-3.4", "bin/pip-3.5", "bin/pip-3.6", "bin/pip-3.7", "bin/pip-3.10"
  skip_clean "bin/easy_install3", "bin/easy_install-3.4", "bin/easy_install-3.5", "bin/easy_install-3.6", "bin/easy_install-3.7", "bin/easy_install-3.10"

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/4d/5b/dc575711b6b8f2f866131a40d053e30e962e633b332acf7cd2c24843d83d/setuptools-69.2.0.tar.gz"
    sha256 "0ff4183f8f42cd8fa3acea16c45205521a4ef28f73c6391d8a25e92893134f2e"
  end

  resource "pip" do
    url "https://files.pythonhosted.org/packages/94/59/6638090c25e9bc4ce0c42817b5a234e183872a1129735a9330c472cc2056/pip-24.0.tar.gz"
    sha256 "ea9bd1a847e8c5774a5777bb398c19e80bcd4e2aa16a4b301b718fe6f593aba2"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/b8/d6/ac9cd92ea2ad502ff7c1ab683806a9deb34711a1e2bd8a59814e8fc27e69/wheel-0.43.0.tar.gz"
    sha256 "465ef92c69fa5c5da2d1cf8ac40559a8c940886afcef87dcf14b9470862f1d85"
  end

  # Homebrew's tcl-tk is built in a standard unix fashion (due to link errors)
  # so we have to stop python from searching for frameworks and linking against
  # X11.
  # Add Support for OS X before 10.6
  # from macports/lang/python310/files/patch-threadid-older-systems.diff
  # and macports/lang/python310/files/patch-no-copyfile-on-Tiger.diff
  patch :p0, :DATA

  # setuptools remembers the build flags python is built with and uses them to
  # build packages later. Xcode-only systems need different flags.
  def pour_bottle?
    MacOS::CLT.installed?
  end

  def install
    # Unset these so that installing pip and setuptools puts them where we want
    # and not into some other Python the user has installed.
    ENV["PYTHONHOME"] = nil
    ENV["PYTHONPATH"] = nil

    xy = (buildpath/"configure.ac").read.slice(/PYTHON_VERSION, (3\.\d\d)/, 1)
    lib_cellar = prefix/"Frameworks/Python.framework/Versions/#{xy}/lib/python#{xy}"

    args = %W[
      --prefix=#{prefix}
      --enable-ipv6
      --datarootdir=#{share}
      --datadir=#{share}
      --enable-framework=#{frameworks}
      --enable-loadable-sqlite-extensions
      --without-ensurepip
      --with-openssl=#{Formula["openssl3"].opt_prefix}
    ]

    args << "--without-gcc" if ENV.compiler == :clang

    cflags   = []
    ldflags  = []
    cppflags = []

    unless MacOS::CLT.installed?
      # Help Python's build system (setuptools/pip) to build things on Xcode-only systems
      # The setup.py looks at "-isysroot" to get the sysroot (and not at --sysroot)
      cflags   << "-isysroot #{MacOS.sdk_path}"
      ldflags  << "-isysroot #{MacOS.sdk_path}"
      cppflags << "-I#{MacOS.sdk_path}/usr/include" # find zlib
    end
    # Avoid linking to libgcc http://code.activestate.com/lists/python-dev/112195/
    args << "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}"

    # We want our readline! This is just to outsmart the detection code,
    # superenv makes cc always find includes/libs!
    inreplace "setup.py",
      "do_readline = self.compiler.find_library_file(self.lib_dirs,
                readline_lib)",
      "do_readline = '#{Formula["readline"].opt_lib}/libhistory.dylib'"

    inreplace "setup.py" do |s|
      s.gsub! "sqlite_setup_debug = False", "sqlite_setup_debug = True"
      s.gsub! "for d_ in self.inc_dirs + sqlite_inc_paths:",
              "for d_ in ['#{Formula["sqlite"].opt_include}']:"
    end

    if build.universal?
      ENV.universal_binary
      args << "--enable-universalsdk" << "--with-universal-archs=intel"
    end

    # Allow python modules to use ctypes.find_library to find homebrew's stuff
    # even if homebrew is not a /usr/local/lib. Try this with:
    # `brew install enchant && pip install pyenchant`
    inreplace "./Lib/ctypes/macholib/dyld.py" do |f|
      f.gsub! "DEFAULT_LIBRARY_FALLBACK = [", "DEFAULT_LIBRARY_FALLBACK = [ '#{HOMEBREW_PREFIX}/lib',"
      f.gsub! "DEFAULT_FRAMEWORK_FALLBACK = [", "DEFAULT_FRAMEWORK_FALLBACK = [ '#{HOMEBREW_PREFIX}/Frameworks',"
    end

    tcl_tk = Formula["tcl-tk"].opt_prefix
    ENV.append "CPPFLAGS", "-I#{tcl_tk}/include"
    ENV.append "LDFLAGS", "-L#{tcl_tk}/lib"

    args << "CFLAGS=#{cflags.join(" ")}" unless cflags.empty?
    args << "LDFLAGS=#{ldflags.join(" ")}" unless ldflags.empty?
    args << "CPPFLAGS=#{cppflags.join(" ")}" unless cppflags.empty?

    system "./configure", *args
    system "make"

    ENV.deparallelize # Installs must be serialized
    # Tell Python not to install into /Applications (default for framework builds)
    system "make", "install", "PYTHONAPPSDIR=#{prefix}"
    # Demos and Tools
    system "make", "frameworkinstallextras", "PYTHONAPPSDIR=#{share}/python3"

    # Any .app get a " 3" attached, so it does not conflict with python 2.x.
    Dir.glob("#{prefix}/*.app") { |app| mv app, app.sub(".app", " 3.app") }

    # A fix, because python and python3 both want to install Python.framework
    # and therefore we can't link both into HOMEBREW_PREFIX/Frameworks
    # https://github.com/Homebrew/homebrew/issues/15943
    ["Headers", "Python", "Resources"].each { |f| rm(prefix/"Frameworks/Python.framework/#{f}") }
    rm prefix/"Frameworks/Python.framework/Versions/Current"

    # Symlink the pkgconfig files into HOMEBREW_PREFIX so they're accessible.
    (lib/"pkgconfig").install_symlink Dir["#{frameworks}/Python.framework/Versions/#{xy}/lib/pkgconfig/*"]

    # Remove 2to3 because python2 also installs it
    rm bin/"2to3"

    # Remove the site-packages that Python created in its Cellar.
    (prefix/"Frameworks/Python.framework/Versions/#{xy}/lib/python#{xy}/site-packages").rmtree

    %w[setuptools pip wheel].each do |r|
      (libexec/r).install resource(r)
    end

    # Install unversioned symlinks in libexec/bin.
    {
      "idle" => "idle3",
      "pydoc" => "pydoc3",
      "python" => "python3",
      "python-config" => "python3-config",
    }.each do |unversioned_name, versioned_name|
      (libexec/"bin").install_symlink (bin/versioned_name).realpath => unversioned_name
    end

    # Installed test data contains prebuilt libraries for 10.9+,
    # which confuses ld in earlier versions of OS X and breaks
    # relocation/bottling attempts.
    (libexec/"wheel/tests/testdata").rmtree
  end

  def post_install
    ENV.delete "PYTHONPATH"

    xy = (prefix/"Frameworks/Python.framework/Versions").children.min.basename.to_s
    site_packages = HOMEBREW_PREFIX/"lib/python#{xy}/site-packages"
    site_packages_cellar = prefix/"Frameworks/Python.framework/Versions/#{xy}/lib/python#{xy}/site-packages"

    # Fix up the site-packages so that user-installed Python software survives
    # minor updates, such as going from 3.3.2 to 3.3.3:

    # Create a site-packages in HOMEBREW_PREFIX/lib/python#{xy}/site-packages
    site_packages.mkpath

    # Symlink the prefix site-packages into the cellar.
    site_packages_cellar.unlink if site_packages_cellar.exist?
    site_packages_cellar.parent.install_symlink site_packages

    # Write our sitecustomize.py
    rm_rf Dir["#{site_packages}/sitecustomize.py[co]"]
    (site_packages/"sitecustomize.py").atomic_write(sitecustomize)

    # Remove old setuptools installations that may still fly around and be
    # listed in the easy_install.pth. This can break setuptools build with
    # zipimport.ZipImportError: bad local file header
    # setuptools-0.9.8-py3.3.egg
    rm_rf Dir["#{site_packages}/setuptools*"]
    rm_rf Dir["#{site_packages}/distribute*"]
    rm_rf Dir["#{site_packages}/pip[-_.][0-9]*", "#{site_packages}/pip"]

    %w[setuptools pip wheel].each do |pkg|
      (libexec/pkg).cd do
        system bin/"python3", "-s", "setup.py", "--no-user-cfg", "install",
               "--force", "--verbose", "--install-scripts=#{bin}",
               "--install-lib=#{site_packages}",
               "--single-version-externally-managed",
               "--record=installed.txt"
      end
    end

    rm_rf [bin/"pip", bin/"easy_install"]
    mv bin/"wheel", bin/"wheel3"

    # Install unversioned symlinks in libexec/bin.
    {
      "pip" => "pip3",
      "wheel" => "wheel3",
    }.each do |unversioned_name, versioned_name|
      (libexec/"bin").install_symlink (bin/versioned_name).realpath => unversioned_name
    end

    # post_install happens after link
    %W[pip3 pip#{xy} wheel3].each do |e|
      (HOMEBREW_PREFIX/"bin").install_symlink bin/e
    end

    # Help distutils find brewed stuff when building extensions
    include_dirs = [HOMEBREW_PREFIX/"include", Formula["openssl3"].opt_include,
                    Formula["sqlite"].opt_include, Formula["tcl-tk"].opt_include]
    library_dirs = [HOMEBREW_PREFIX/"lib", Formula["openssl3"].opt_lib,
                    Formula["sqlite"].opt_lib, Formula["tcl-tk"].opt_lib]

    cfg = prefix/"Frameworks/Python.framework/Versions/#{xy}/lib/python#{xy}/distutils/distutils.cfg"

    cfg.atomic_write <<~EOS
      [install]
      prefix=#{HOMEBREW_PREFIX}

      [build_ext]
      include_dirs=#{include_dirs.join ":"}
      library_dirs=#{library_dirs.join ":"}
    EOS
  end

  def sitecustomize
    xy = (prefix/"Frameworks/Python.framework/Versions").children.min.basename.to_s

    <<~EOS
      # This file is created by Homebrew and is executed on each python startup.
      # Don't print from here, or else python command line scripts may fail!
      # <https://docs.brew.sh/Homebrew-and-Python>
      import re
      import os
      import sys

      if sys.version_info[0] != 3:
          # This can only happen if the user has set the PYTHONPATH for 3.x and run Python 2.x or vice versa.
          # Every Python looks at the PYTHONPATH variable and we can't fix it here in sitecustomize.py,
          # because the PYTHONPATH is evaluated after the sitecustomize.py. Many modules (e.g. PyQt4) are
          # built only for a specific version of Python and will fail with cryptic error messages.
          # In the end this means: Don't set the PYTHONPATH permanently if you use different Python versions.
          exit('Your PYTHONPATH points to a site-packages dir for Python 3.x but you are running Python ' +
               str(sys.version_info[0]) + '.x!\\n     PYTHONPATH is currently: "' + str(os.environ['PYTHONPATH']) + '"\\n' +
               '     You should `unset PYTHONPATH` to fix this.')

      # Only do this for a brewed python:
      if os.path.realpath(sys.executable).startswith('#{rack}'):
          # Shuffle /Library site-packages to the end of sys.path
          library_site = '/Library/Python/#{xy}/site-packages'
          library_packages = [p for p in sys.path if p.startswith(library_site)]
          sys.path = [p for p in sys.path if not p.startswith(library_site)]
          # .pth files have already been processed so don't use addsitedir
          sys.path.extend(library_packages)

          # the Cellar site-packages is a symlink to the HOMEBREW_PREFIX
          # site_packages; prefer the shorter paths
          long_prefix = re.compile(r'#{rack}/[0-9\._abrc]+/Frameworks/Python\.framework/Versions/#{xy}/lib/python#{xy}/site-packages')
          sys.path = [long_prefix.sub('#{HOMEBREW_PREFIX/"lib/python#{xy}/site-packages"}', p) for p in sys.path]

          # Set the sys.executable to use the opt_prefix
          sys.executable = '#{opt_bin}/python#{xy}'
    EOS
  end

  def caveats
    if prefix.exist?
      xy = (prefix/"Frameworks/Python.framework/Versions").children.min.basename.to_s
    else
      xy = version.to_s.slice(/(3\.\d\d)/) || "3.10"
    end
    text = <<~EOS
      Python has been installed as
        #{HOMEBREW_PREFIX}/bin/python3

      Unversioned symlinks `python`, `python-config`, `pip` etc. pointing to
      `python3`, `python3-config`, `pip3` etc., respectively, have been installed into
        #{opt_libexec}/bin

      If you need Homebrew's Python 2.7 run
        brew install python

      Pip, setuptools, and wheel have been installed. To update them run
        pip3 install --upgrade pip setuptools wheel

      You can install Python packages with
        pip3 install <package>
      They will install into the site-package directory
        #{HOMEBREW_PREFIX/"lib/python#{xy}/site-packages"}

      See: https://docs.brew.sh/Homebrew-and-Python
    EOS

    # Tk warning only for 10.6
    tk_caveats = <<~EOS

      Apple's Tcl/Tk is not recommended for use with Python on Mac OS X 10.6.
      For more information see: https://www.python.org/download/mac/tcltk/
    EOS

    text += tk_caveats unless MacOS.version >= :lion
    text
  end

  test do
    xy = (prefix/"Frameworks/Python.framework/Versions").children.min.basename.to_s
    # Check if sqlite is ok, because we build with --enable-loadable-sqlite-extensions
    # and it can occur that building sqlite silently fails if OSX's sqlite is used.
    system "#{bin}/python#{xy}", "-c", "import sqlite3"
    # Check if some other modules import. Then the linked libs are working.
    system "#{bin}/python#{xy}", "-c", "import tkinter; root = tkinter.Tk()"
    system bin/"pip3", "list"
  end
end

__END__
--- setup.py
+++ setup.py
@@ -2111,12 +2111,6 @@
         if self.detect_tkinter_fromenv():
             return True
 
-        # Rather than complicate the code below, detecting and building
-        # AquaTk is a separate method. Only one Tkinter will be built on
-        # Darwin - either AquaTk, if it is found, or X11 based Tk.
-        if (MACOS and self.detect_tkinter_darwin()):
-            return True
-
         # Assume we haven't found any of the libraries or include files
         # The versions with dots are used on Unix, and the versions without
         # dots on Windows, for detection by cygwin.
@@ -2164,22 +2158,6 @@
             if dir not in include_dirs:
                 include_dirs.append(dir)
 
-        # Check for various platform-specific directories
-        if HOST_PLATFORM == 'sunos5':
-            include_dirs.append('/usr/openwin/include')
-            added_lib_dirs.append('/usr/openwin/lib')
-        elif os.path.exists('/usr/X11R6/include'):
-            include_dirs.append('/usr/X11R6/include')
-            added_lib_dirs.append('/usr/X11R6/lib64')
-            added_lib_dirs.append('/usr/X11R6/lib')
-        elif os.path.exists('/usr/X11R5/include'):
-            include_dirs.append('/usr/X11R5/include')
-            added_lib_dirs.append('/usr/X11R5/lib')
-        else:
-            # Assume default location for X11
-            include_dirs.append('/usr/X11/include')
-            added_lib_dirs.append('/usr/X11/lib')
-
         # If Cygwin, then verify that X is installed before proceeding
         if CYGWIN:
             x11_inc = find_file('X11/Xlib.h', [], include_dirs)
@@ -2200,10 +2178,6 @@
         libs.append('tk'+ version)
         libs.append('tcl'+ version)
 
-        # Finally, link with the X11 libraries (not appropriate on cygwin)
-        if not CYGWIN:
-            libs.append('X11')
-
         # XXX handle these, but how to detect?
         # *** Uncomment and edit for PIL (TkImaging) extension only:
         #       -DWITH_PIL -I../Extensions/Imaging/libImaging  tkImaging.c \
--- Modules/posixmodule.c
+++ Modules/posixmodule.c
@@ -66,6 +66,8 @@
  */
 #if defined(__APPLE__)
 
+#include <AvailabilityMacros.h>
+
 #if defined(__has_builtin)
 #if __has_builtin(__builtin_available)
 #define HAVE_BUILTIN_AVAILABLE 1
@@ -238,7 +240,7 @@ corresponding Unix manual entries for mo
 #  include <sys/sendfile.h>
 #endif
 
-#if defined(__APPLE__)
+#if defined(__APPLE__) && MAC_OS_X_VERSION_MAX_ALLOWED >= 1050
 #  include <copyfile.h>
 #endif
 
@@ -9997,7 +9999,7 @@ done:
 #endif /* HAVE_SENDFILE */
 
 
-#if defined(__APPLE__)
+#if defined(__APPLE__) && MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
 /*[clinic input]
 os._fcopyfile
 
@@ -15440,7 +15442,7 @@ all_ins(PyObject *m)
 #endif
 #endif  /* HAVE_EVENTFD && EFD_CLOEXEC */
 
-#if defined(__APPLE__)
+#if defined(__APPLE__) && MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
     if (PyModule_AddIntConstant(m, "_COPYFILE_DATA", COPYFILE_DATA)) return -1;
 #endif
 
--- Modules/clinic/posixmodule.c.h
+++ Modules/clinic/posixmodule.c.h
@@ -5270,7 +5270,7 @@ exit:
 
 #endif /* defined(HAVE_SENDFILE) && !defined(__APPLE__) && !(defined(__FreeBSD__) || defined(__DragonFly__)) */
 
-#if defined(__APPLE__)
+#if defined(__APPLE__) && MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
 
 PyDoc_STRVAR(os__fcopyfile__doc__,
 "_fcopyfile($module, in_fd, out_fd, flags, /)\n"
--- Modules/pyexpat.c
+++ Modules/pyexpat.c
@@ -1185,7 +1185,8 @@ newxmlparseobject(pyexpat_state *state, 
 static int
 xmlparse_traverse(xmlparseobject *op, visitproc visit, void *arg)
 {
-    for (int i = 0; handler_info[i].name != NULL; i++) {
+    int i;
+    for (i = 0; handler_info[i].name != NULL; i++) {
         Py_VISIT(op->handlers[i]);
     }
     Py_VISIT(Py_TYPE(op));
@@ -1814,13 +1815,14 @@ add_model_module(PyObject *mod)
 static int
 add_features(PyObject *mod)
 {
+    size_t i;
     PyObject *list = PyList_New(0);
     if (list == NULL) {
         return -1;
     }
 
     const XML_Feature *features = XML_GetFeatureList();
-    for (size_t i = 0; features[i].feature != XML_FEATURE_END; ++i) {
+    for (i = 0; features[i].feature != XML_FEATURE_END; ++i) {
         PyObject *item = Py_BuildValue("si", features[i].name,
                                        features[i].value);
         if (item == NULL) {
--- Python/thread_pthread.h
+++ Python/thread_pthread.h
@@ -343,7 +346,17 @@ PyThread_get_thread_native_id(void)
         PyThread_init_thread();
 #ifdef __APPLE__
     uint64_t native_id;
+#if MAC_OS_X_VERSION_MAX_ALLOWED < 1060
+    native_id = pthread_mach_thread_np(pthread_self());
+#elif MAC_OS_X_VERSION_MIN_REQUIRED < 1060
+    if (&pthread_threadid_np != NULL) {
+	(void) pthread_threaded_np(NULL, &native_id);
+    } else {
+	native_id = pthread_mach_threaded_np(pthread_self());
+    }
+#else
     (void) pthread_threadid_np(NULL, &native_id);
+#endif
 #elif defined(__linux__)
     pid_t native_id;
     native_id = syscall(SYS_gettid);
--- Lib/test/test_shutil.py
+++ Lib/test/test_shutil.py
@@ -2451,7 +2451,7 @@ class TestZeroCopySendfile(_ZeroCopyFileTest, unittest.TestCase):
             shutil._USE_CP_SENDFILE = True
 
 
-@unittest.skipIf(not MACOS, 'macOS only')
+@unittest.skipIf(not MACOS or not hasattr(posix, "_fcopyfile"), 'macOS with posix._fcopyfile only')
 class TestZeroCopyMACOS(_ZeroCopyFileTest, unittest.TestCase):
     PATCHPOINT = "posix._fcopyfile"
 

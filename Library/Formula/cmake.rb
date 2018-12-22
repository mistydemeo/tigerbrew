class Cmake < Formula
  desc "Cross-platform make"
  homepage "http://www.cmake.org/"
  url "https://cmake.org/files/v3.13/cmake-3.13.2.tar.gz"
  sha256 "c925e7d2c5ba511a69f43543ed7b4182a7d446c274c7480d0e42cd933076ae25"

  head "https://cmake.org/cmake.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "81a8b6e3b7f527edb89c298c8aea367e7fb00bf83f30fc4ee814e0d06b75f3dc" => :sierra
    sha256 "e0e81368fe89f206582833d5f289c6fc56ee0272b1913361e65e3221efadf447" => :el_capitan
    sha256 "16f91ff94d784b2120e248650a7a99c5974d325900f94ead54392b2fdaabeb8e" => :yosemite
  end

#  devel do
#    url "https://cmake.org/files/v3.7/cmake-3.7.0-rc3.tar.gz"
#    sha256 "654a5f0400c88fb07cf7e882e6254d17f248663b51a85ff07d79f7ee7b4795bd"
#  end

  option "without-docs", "Don't build man pages"
  option "with-completion", "Install Bash completion (Has potential problems with system bash)"

  depends_on :python => :build if MacOS.version <= :snow_leopard && build.with?("docs")

  needs :cxx11
  patch :DATA

  # The `with-qt` GUI option was removed due to circular dependencies if
  # CMake is built with Qt support and Qt is built with MySQL support as MySQL uses CMake.
  # For the GUI application please instead use brew install caskroom/cask/cmake.

  resource "sphinx_rtd_theme" do
    url "https://pypi.python.org/packages/source/s/sphinx_rtd_theme/sphinx_rtd_theme-0.1.8.tar.gz"
    sha256 "74f633ed3a61da1d1d59c3185483c81a9d7346bf0e7b5f29ad0764a6f159b68a"
  end

  resource "snowballstemmer" do
    url "https://pypi.python.org/packages/source/s/snowballstemmer/snowballstemmer-1.2.0.tar.gz"
    sha256 "6d54f350e7a0e48903a4e3b6b2cabd1b43e23765fbc975065402893692954191"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  resource "pygments" do
    url "https://pypi.python.org/packages/source/P/Pygments/Pygments-2.0.2.tar.gz"
    sha256 "7320919084e6dac8f4540638a46447a3bd730fca172afc17d2c03eed22cf4f51"
  end

  resource "docutils" do
    url "https://pypi.python.org/packages/source/d/docutils/docutils-0.12.tar.gz"
    sha256 "c7db717810ab6965f66c8cf0398a98c9d8df982da39b4cd7f162911eb89596fa"
  end

  resource "pytz" do
    url "https://pypi.python.org/packages/source/p/pytz/pytz-2015.4.tar.bz2"
    sha256 "a78b484d5472dd8c688f8b3eee18646a25c66ce45b2c26652850f6af9ce52b17"
  end

  resource "babel" do
    url "https://pypi.python.org/packages/source/B/Babel/Babel-2.0.tar.gz"
    sha256 "44988df191123065af9857eca68e9151526a931c12659ca29904e4f11de7ec1b"
  end

  resource "markupsafe" do
    url "https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.23.tar.gz"
    sha256 "a4ec1aff59b95a14b45eb2e23761a0179e98319da5a7eb76b56ea8cdc7b871c3"
  end

  resource "jinja2" do
    url "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.8.tar.gz"
    sha256 "bc1ff2ff88dbfacefde4ddde471d1417d3b304e8df103a7a9437d47269201bf4"
  end

  resource "alabaster" do
    url "https://pypi.python.org/packages/source/a/alabaster/alabaster-0.7.6.tar.gz"
    sha256 "309d33e0282c8209f792f3527f41ec04e508ff837c61fc1906dde988a256deeb"
  end

  resource "sphinx" do
    url "https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.3.1.tar.gz"
    sha256 "1a6e5130c2b42d2de301693c299f78cc4bd3501e78b610c08e45efc70e2b5114"
  end

  def install
    if build.with? "docs"
      ENV.prepend_create_path "PYTHONPATH", buildpath/"sphinx/lib/python2.7/site-packages"
      resources.each do |r|
        r.stage do
          system "python", *Language::Python.setup_install_args(buildpath/"sphinx")
        end
      end

      # There is an existing issue around OS X & Python locale setting
      # See http://bugs.python.org/issue18378#msg215215 for explanation
      ENV["LC_ALL"] = "en_US.UTF-8"
    end

    args = %W[
      --prefix=#{prefix}
      --no-system-libs
      --parallel=#{ENV.make_jobs}
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
      --system-zlib
      --system-bzip2
    ]

    # https://github.com/Homebrew/legacy-homebrew/issues/45989
    if MacOS.version <= :lion
      args << "--no-system-curl"
    else
      args << "--system-curl"
    end

    if build.with? "docs"
      args << "--sphinx-man" << "--sphinx-build=#{buildpath}/sphinx/bin/sphinx-build"
    end

    # gcc-4.2 does not find stdarg.h if the sysroot is set to an SDK
    args << "--" << "-DCMAKE_OSX_SYSROOT=/"

    system "./bootstrap", *args
    system "make"
    system "make", "install"

    if build.with? "completion"
      cd "Auxiliary/bash-completion/" do
        bash_completion.install "ctest", "cmake", "cpack"
      end
    end

    (share/"emacs/site-lisp/cmake").install "Auxiliary/cmake-mode.el"
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system "#{bin}/cmake", "."
  end
end


__END__
diff -u -r cmake-3.13.2/Source/CMakeLists.txt cmake-3.13.2-patched/Source/CMakeLists.txt
--- cmake-3.13.2/Source/CMakeLists.txt	2018-12-13 12:57:40.000000000 +0100
+++ cmake-3.13.2-patched/Source/CMakeLists.txt	2018-12-16 14:40:06.000000000 +0100
@@ -793,7 +793,7 @@
 
 # On Apple we need CoreFoundation
 if(APPLE)
-  target_link_libraries(CMakeLib "-framework CoreFoundation")
+  target_link_libraries(CMakeLib "-framework CoreFoundation -framework ApplicationServices")
 endif()
 
 if(WIN32 AND NOT UNIX)
diff -u -r cmake-3.13.2/Utilities/cmlibuv/src/unix/core.c cmake-3.13.2-patched/Utilities/cmlibuv/src/unix/core.c
--- cmake-3.13.2/Utilities/cmlibuv/src/unix/core.c	2018-12-13 12:57:42.000000000 +0100
+++ cmake-3.13.2-patched/Utilities/cmlibuv/src/unix/core.c	2018-12-16 14:41:49.000000000 +0100
@@ -1293,8 +1293,7 @@
   if (name == NULL)
     return UV_EINVAL;
 
-  if (unsetenv(name) != 0)
-    return UV__ERR(errno);
+  unsetenv(name);
 
   return 0;
 }
diff -u -r cmake-3.13.2/Utilities/cmlibuv/src/unix/darwin-proctitle.c cmake-3.13.2-patched/Utilities/cmlibuv/src/unix/darwin-proctitle.c
--- cmake-3.13.2/Utilities/cmlibuv/src/unix/darwin-proctitle.c	2018-12-13 12:57:42.000000000 +0100
+++ cmake-3.13.2-patched/Utilities/cmlibuv/src/unix/darwin-proctitle.c	2018-12-16 16:01:36.000000000 +0100
@@ -29,6 +29,9 @@
 #include <TargetConditionals.h>
 
 #if !TARGET_OS_IPHONE
+#undef TCP_NODELAY
+#undef TCP_MAXSEG
+#undef TCP_KEEPALIVE
 # include <CoreFoundation/CoreFoundation.h>
 # include <ApplicationServices/ApplicationServices.h>
 #endif
diff -u -r cmake-3.13.2/Utilities/cmlibuv/src/unix/fs.c cmake-3.13.2-patched/Utilities/cmlibuv/src/unix/fs.c
--- cmake-3.13.2/Utilities/cmlibuv/src/unix/fs.c	2018-12-13 12:57:42.000000000 +0100
+++ cmake-3.13.2-patched/Utilities/cmlibuv/src/unix/fs.c	2018-12-16 14:40:06.000000000 +0100
@@ -60,7 +60,7 @@
 # include <sys/sendfile.h>
 #endif
 
-#if defined(__APPLE__)
+#if 0 && defined(__APPLE__)
 # include <copyfile.h>
 #elif defined(__linux__) && !defined(FICLONE)
 # include <sys/ioctl.h>
@@ -674,7 +674,7 @@
 
     return -1;
   }
-#elif defined(__APPLE__)           || \
+#elif 0 && defined(__APPLE__)           || \
       defined(__DragonFly__)       || \
       defined(__FreeBSD__)         || \
       defined(__FreeBSD_kernel__)
@@ -825,7 +825,7 @@
 }
 
 static ssize_t uv__fs_copyfile(uv_fs_t* req) {
-#if defined(__APPLE__) && !TARGET_OS_IPHONE
+#if 0 && defined(__APPLE__) && !TARGET_OS_IPHONE
   /* On macOS, use the native copyfile(3). */
   copyfile_flags_t flags;
 
@@ -991,8 +991,8 @@
   dst->st_mtim.tv_nsec = src->st_mtimespec.tv_nsec;
   dst->st_ctim.tv_sec = src->st_ctimespec.tv_sec;
   dst->st_ctim.tv_nsec = src->st_ctimespec.tv_nsec;
-  dst->st_birthtim.tv_sec = src->st_birthtimespec.tv_sec;
-  dst->st_birthtim.tv_nsec = src->st_birthtimespec.tv_nsec;
+  dst->st_birthtim.tv_sec = src->st_ctimespec.tv_sec;
+  dst->st_birthtim.tv_nsec = src->st_ctimespec.tv_nsec;
   dst->st_flags = src->st_flags;
   dst->st_gen = src->st_gen;
 #elif defined(__ANDROID__)
diff -u -r cmake-3.13.2/Utilities/cmlibuv/src/unix/fsevents.c cmake-3.13.2-patched/Utilities/cmlibuv/src/unix/fsevents.c
--- cmake-3.13.2/Utilities/cmlibuv/src/unix/fsevents.c	2018-12-13 12:57:42.000000000 +0100
+++ cmake-3.13.2-patched/Utilities/cmlibuv/src/unix/fsevents.c	2018-12-16 14:40:06.000000000 +0100
@@ -21,7 +21,7 @@
 #include "uv.h"
 #include "internal.h"
 
-#if TARGET_OS_IPHONE
+#if 1 || TARGET_OS_IPHONE
 
 /* iOS (currently) doesn't provide the FSEvents-API (nor CoreServices) */
 
diff -u -r cmake-3.13.2/Utilities/cmlibuv/src/unix/tty.c cmake-3.13.2-patched/Utilities/cmlibuv/src/unix/tty.c
--- cmake-3.13.2/Utilities/cmlibuv/src/unix/tty.c	2018-12-13 12:57:42.000000000 +0100
+++ cmake-3.13.2-patched/Utilities/cmlibuv/src/unix/tty.c	2018-12-16 14:40:06.000000000 +0100
@@ -44,7 +44,7 @@
   int dummy;
 
   result = ioctl(fd, TIOCGPTN, &dummy) != 0;
-#elif defined(__APPLE__)
+#elif 0 && defined(__APPLE__)
   char dummy[256];
 
   result = ioctl(fd, TIOCPTYGNAME, &dummy) != 0;

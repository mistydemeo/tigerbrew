class Libuv < Formula
  desc "Multi-platform support library with a focus on asynchronous I/O"
  homepage "https://libuv.org"
  url "https://dist.libuv.org/dist/v1.44.2/libuv-v1.44.2-dist.tar.gz"
  sha256 "8ff28f6ac0d6d2a31d2eeca36aff3d7806706c7d3f5971f5ee013ddb0bdd2e9e"
  head "https://github.com/libuv/libuv.git", :branch => "v1.x"

  bottle do
  end

  fails_with :gcc_4_0 do
    cause "lacks __sync_val_compare_and_swap()"
  end

  # Based on patches from macports
  # devel/libuv/files/patch-libuv-legacy.diff
  # devel/libuv/files/patch-libuv-unix-core-close-nocancel.diff
  # src/unix/solaris.c includes an implementation of strnlen(), copy it
  # Make up for the lack of _SC_NPROCESSORS_ONLN on Tiger
  patch :p0, :DATA

  option "without-docs", "Don't build and install documentation"
  option "with-check", "Execute compile time checks (Requires internet connection)"
  option :universal

  depends_on "pkg-config" => :build
  depends_on :python => :build if build.with?("docs")
  depends_on "libutil" if MacOS.version == :tiger

  resource "alabaster" do
    url "https://pypi.python.org/packages/source/a/alabaster/alabaster-0.7.4.tar.gz"
    sha256 "ce77e2fdbaabaae393ffce2a6252a0a666e3977c6c2fa1c48c4ded0569785951"
  end

  resource "babel" do
    url "https://pypi.python.org/packages/source/B/Babel/Babel-1.3.tar.gz"
    sha256 "9f02d0357184de1f093c10012b52e7454a1008be6a5c185ab7a3307aceb1d12e"
  end

  resource "docutils" do
    url "https://pypi.python.org/packages/source/d/docutils/docutils-0.12.tar.gz"
    sha256 "c7db717810ab6965f66c8cf0398a98c9d8df982da39b4cd7f162911eb89596fa"
  end

  resource "pygments" do
    url "https://pypi.python.org/packages/source/P/Pygments/Pygments-2.0.2.tar.gz"
    sha256 "7320919084e6dac8f4540638a46447a3bd730fca172afc17d2c03eed22cf4f51"
  end

  resource "jinja2" do
    url "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.3.tar.gz"
    sha256 "2e24ac5d004db5714976a04ac0e80c6df6e47e98c354cb2c0d82f8879d4f8fdb"
  end

  resource "markupsafe" do
    url "https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.23.tar.gz"
    sha256 "a4ec1aff59b95a14b45eb2e23761a0179e98319da5a7eb76b56ea8cdc7b871c3"
  end

  resource "snowballstemmer" do
    url "https://pypi.python.org/packages/source/s/snowballstemmer/snowballstemmer-1.2.0.tar.gz"
    sha256 "6d54f350e7a0e48903a4e3b6b2cabd1b43e23765fbc975065402893692954191"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  resource "pytz" do
    url "https://pypi.python.org/packages/source/p/pytz/pytz-2015.4.tar.bz2"
    sha256 "a78b484d5472dd8c688f8b3eee18646a25c66ce45b2c26652850f6af9ce52b17"
  end

  resource "sphinx" do
    url "https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.3.1.tar.gz"
    sha256 "1a6e5130c2b42d2de301693c299f78cc4bd3501e78b610c08e45efc70e2b5114"
  end

  resource "sphinx_rtd_theme" do
    url "https://pypi.python.org/packages/source/s/sphinx_rtd_theme/sphinx_rtd_theme-0.1.7.tar.gz"
    sha256 "9a490c861f6cf96a0050c29a92d5d1e01eda02ae6f50760ad5c96a327cdf14e8"
  end

  def install
    ENV.universal_binary if build.universal?
    # Expects unsetenv() to return a value
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version == :tiger

    if build.with? "docs"
      ENV.prepend_create_path "PYTHONPATH", buildpath/"sphinx/lib/python2.7/site-packages"
      resources.each do |r|
        r.stage do
          system "python", *Language::Python.setup_install_args(buildpath/"sphinx")
        end
      end
      ENV.prepend_path "PATH", buildpath/"sphinx/bin"
      # This isn't yet handled by the make install process sadly.
      cd "docs" do
        system "make", "man"
        system "make", "singlehtml"
        man1.install "build/man/libuv.1"
        doc.install Dir["build/singlehtml/*"]
      end
    end

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "check" if build.with? "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <uv.h>
      #include <stdlib.h>

      int main()
      {
        uv_loop_t* loop = malloc(sizeof *loop);
        uv_loop_init(loop);
        uv_loop_close(loop);
        free(loop);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{Formula["libuv"].opt_lib}", "-I#{Formula["libuv"].opt_include}", "-luv", "-o", "test"
    system "./test"
  end
end
__END__
--- src/unix/darwin-proctitle.c.orig
+++ src/unix/darwin-proctitle.c
@@ -41,9 +41,11 @@
   strncpy(namebuf, name, sizeof(namebuf) - 1);
   namebuf[sizeof(namebuf) - 1] = '\0';
 
+#if TARGET_OS_IPHONE || (MAC_OS_X_VERSION_MIN_REQUIRED >= 1060)
   err = pthread_setname_np(namebuf);
   if (err)
     return UV__ERR(err);
+#endif
 
   return 0;
 }
--- src/unix/process.c.orig
+++ src/unix/process.c
@@ -36,7 +36,9 @@
 #include <poll.h>
 
 #if defined(__APPLE__)
+#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1050
 # include <spawn.h>
+#endif
 # include <paths.h>
 # include <sys/kauth.h>
 # include <sys/types.h>
@@ -387,7 +389,7 @@
 #endif
 
 
-#if defined(__APPLE__)
+#if defined(__APPLE__) && (MAC_OS_X_VERSION_MIN_REQUIRED >= 1050)
 typedef struct uv__posix_spawn_fncs_tag {
   struct {
     int (*addchdir_np)(const posix_spawn_file_actions_t *, const char *);
@@ -588,9 +590,11 @@
       }
     }
 
+#if MAC_OS_X_VERSION_MIN_REQUIRED >= 1070
     if (fd == use_fd)
         err = posix_spawn_file_actions_addinherit_np(actions, fd);
     else
+#endif
         err = posix_spawn_file_actions_adddup2(actions, use_fd, fd);
     assert(err != ENOSYS);
     if (err != 0)
@@ -839,7 +843,7 @@
   int exec_errorno;
   ssize_t r;
 
-#if defined(__APPLE__)
+#if defined(__APPLE__) && (MAC_OS_X_VERSION_MIN_REQUIRED >= 1050)
   uv_once(&posix_spawn_init_once, uv__spawn_init_posix_spawn);
 
   /* Special child process spawn case for macOS Big Sur (11.0) onwards
--- src/unix/tty.c.orig
+++ src/unix/tty.c
@@ -85,7 +85,7 @@
   int dummy;
 
   result = ioctl(fd, TIOCGPTN, &dummy) != 0;
-#elif defined(__APPLE__)
+#elif defined(__APPLE__) && MAC_OS_X_VERSION_MAX_ALLOWED >= 1050
   char dummy[256];
 
   result = ioctl(fd, TIOCPTYGNAME, &dummy) != 0;
--- src/unix/udp.c.orig
+++ src/unix/udp.c
@@ -938,6 +938,7 @@
     !defined(__ANDROID__) &&                                        \
     !defined(__DragonFly__) &&                                      \
     !defined(__QNX__) &&                                            \
+    (!defined(__APPLE__) || (MAC_OS_X_VERSION_MAX_ALLOWED >= 1070)) && \
     !defined(__GNU__)
 static int uv__udp_set_source_membership4(uv_udp_t* handle,
                                           const struct sockaddr_in* multicast_addr,
@@ -1131,6 +1132,7 @@
     !defined(__ANDROID__) &&                                        \
     !defined(__DragonFly__) &&                                      \
     !defined(__QNX__) &&                                            \
+    (!defined(__APPLE__) || (MAC_OS_X_VERSION_MAX_ALLOWED >= 1070)) && \
     !defined(__GNU__)
   int err;
   union uv__sockaddr mcast_addr;
--- test/test-fs.c.orig
+++ test/test-fs.c
@@ -1410,7 +1410,7 @@
   ASSERT(0 == uv_fs_fstat(NULL, &req, file, NULL));
   ASSERT(req.result == 0);
   s = req.ptr;
-# if defined(__APPLE__)
+# if defined(__APPLE__) && (__ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050)
   ASSERT(s->st_birthtim.tv_sec == t.st_birthtimespec.tv_sec);
   ASSERT(s->st_birthtim.tv_nsec == t.st_birthtimespec.tv_nsec);
 # elif defined(__linux__)
@@ -1451,7 +1451,7 @@
   ASSERT(s->st_size == (uint64_t) t.st_size);
   ASSERT(s->st_blksize == (uint64_t) t.st_blksize);
   ASSERT(s->st_blocks == (uint64_t) t.st_blocks);
-#if defined(__APPLE__)
+#if defined(__APPLE__) && (__ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ >= 1050)
   ASSERT(s->st_atim.tv_sec == t.st_atimespec.tv_sec);
   ASSERT(s->st_atim.tv_nsec == t.st_atimespec.tv_nsec);
   ASSERT(s->st_mtim.tv_sec == t.st_mtimespec.tv_sec);
--- src/unix/core.c.orig	2022-07-11 18:06:28.000000000 +0100
+++ src/unix/core.c	2024-11-13 18:22:26.000000000 +0000
@@ -553,18 +553,31 @@
  * will unwind the thread when it's in the cancel state. Work around that
  * by making the system call directly. Musl libc is unaffected.
  */
+
+#if defined(__GNUC__)
+# define GCC_VERSION \
+	(__GNUC__ * 10000 + __GNUC_MINOR__ * 100 + __GNUC_PATCHLEVEL__)
+#endif
+#if defined(__clang__) || (defined(GCC_VERSION) && (GCC_VERSION >= 40500))
+/* gcc diagnostic pragmas available */
+# define GCC_DIAGNOSTIC_AVAILABLE
+#endif
 int uv__close_nocancel(int fd) {
-#if defined(__APPLE__)
-#pragma GCC diagnostic push
-#pragma GCC diagnostic ignored "-Wdollar-in-identifier-extension"
-#if defined(__LP64__) || TARGET_OS_IPHONE
+#if defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED >= 1050)
+# if defined(GCC_DIAGNOSTIC_AVAILABLE)
+#  pragma GCC diagnostic push
+#  pragma GCC diagnostic ignored "-Wdollar-in-identifier-extension"
+# endif
+# if defined(__LP64__) || __LP64__ || (defined(TARGET_OS_IPHONE) && (TARGET_OS_IPHONE > 0))
   extern int close$NOCANCEL(int);
   return close$NOCANCEL(fd);
-#else
+# else
   extern int close$NOCANCEL$UNIX2003(int);
   return close$NOCANCEL$UNIX2003(fd);
-#endif
-#pragma GCC diagnostic pop
+# endif
+# if defined(GCC_DIAGNOSTIC_AVAILABLE)
+#  pragma GCC diagnostic pop
+# endif
 #elif defined(__linux__) && defined(__SANITIZE_THREAD__) && defined(__clang__)
   long rc;
   __sanitizer_syscall_pre_close(fd);
@@ -1657,6 +1670,9 @@
   return (unsigned) rc;
 #else  /* __linux__ */
   long rc;
+  #ifndef _SC_NPROCESSORS_ONLN
+  #define _SC_NPROCESSORS_ONLN 58
+  #endif
 
   rc = sysconf(_SC_NPROCESSORS_ONLN);
   if (rc < 1)
--- src/unix/darwin.c.orig	2024-11-13 18:37:35.000000000 +0000
+++ src/unix/darwin.c	2024-11-13 18:38:00.000000000 +0000
@@ -377,3 +377,13 @@
 
   return 0;
 }
+
+#if !defined(_POSIX_VERSION) || _POSIX_VERSION < 200809L
+size_t strnlen(const char* s, size_t maxlen) {
+  const char* end;
+  end = memchr(s, '\0', maxlen);
+  if (end == NULL)
+    return maxlen;
+  return end - s;
+}
+#endif
--- src/unix/fs.c.orig	2022-05-25 14:21:41.000000000 +0100
+++ src/unix/fs.c	2024-11-13 18:58:17.000000000 +0000
@@ -1061,7 +1061,7 @@
 
     return -1;
   }
-#elif defined(__APPLE__)           || \
+#elif (defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED >= 1050)) || \
       defined(__DragonFly__)       || \
       defined(__FreeBSD__)         || \
       defined(__FreeBSD_kernel__)
@@ -1187,7 +1187,7 @@
   ts[0] = uv__fs_to_timespec(req->atime);
   ts[1] = uv__fs_to_timespec(req->mtime);
   return utimensat(AT_FDCWD, req->path, ts, AT_SYMLINK_NOFOLLOW);
-#elif defined(__APPLE__)          ||                                          \
+#elif defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED >= 1050) ||         \
       defined(__DragonFly__)      ||                                          \
       defined(__FreeBSD__)        ||                                          \
       defined(__FreeBSD_kernel__) ||                                          \
@@ -1441,7 +1441,7 @@
   dst->st_blksize = src->st_blksize;
   dst->st_blocks = src->st_blocks;
 
-#if defined(__APPLE__)
+#if defined(__APPLE__) && (MAC_OS_X_VERSION_MAX_ALLOWED >= 1050)
   dst->st_atim.tv_sec = src->st_atimespec.tv_sec;
   dst->st_atim.tv_nsec = src->st_atimespec.tv_nsec;
   dst->st_mtim.tv_sec = src->st_mtimespec.tv_sec;

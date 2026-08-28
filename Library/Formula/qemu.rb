class Qemu < Formula
  desc "x86 and PowerPC Emulator"
  homepage "http://wiki.qemu.org"
  url "https://download.qemu.org/qemu-5.1.0.tar.xz"
  sha256 "c9174eb5933d9eb5e61f541cd6d1184cd3118dfe4c5c4955bc1bdc4d390fa4e5"
  #url "https://download.qemu.org/qemu-5.2.0.tar.xz"
  #sha256 "5efe9b9fc4cb19c5ef0e59115f9c2ea2c37c5c042caceb88fc1da97f0e58740e"
  #url "https://download.qemu.org/qemu-2.3.1.tar.bz2"
  #sha256 "661d029809421cae06b4b1bc74ac0e560cb4ed47c9523c676ff277fa26dca15f"

  depends_on "make" => :build if MacOS.version < :leopard
  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "jpeg"
  depends_on "glib"
  depends_on "libutil" if MacOS.version < :leopard
  depends_on "pixman"
  depends_on "ncurses"
  depends_on "python3" => :build
  depends_on "vde" => :optional
  depends_on "sdl" => :optional
  depends_on "gtk+" => :optional
  # depends_on "libssh2" => :optional
  depends_on "zlib"
  depends_on "bzip2"

  # 3.2MB working disc-image file hosted on upstream's servers for people to use to test qemu functionality.
  resource "armtest" do
    url "https://www.nongnu.org/qemu/arm-test-0.2.tar.gz"
    sha256 "4b4c2dce4c055f0a2adb93d571987a3d40c96c6cbfd9244d19b9708ce5aea454"
  end

  #patch do
    # Portability fix - qemu binaries exit with "qobject/qjson.c:69: failed assertion `obj != NULL'" error
    # https://lists.gnu.org/archive/html/qemu-devel/2016-11/msg04186.html
    #url "https://gitlab.com/qemu-project/qemu/-/commit/043b5a49516f5037430e7864e23fc2fdd39f2b10.diff"
    #sha256 "db0419e2875a8057580c6b8d18938e6fff300b964b68d90ea77c0c237c582d67"
  #end

  #patch do
  #  url "https://github.com/vivier/qemu-m68k/commit/2f75bd73c319a1224a64a1b5ad680b1a37ed2d7a.diff"
  #  sha256 "953399aa8fde33375de475a62698fc095d575ba38bed50bcc2cd5c3372f2e216"
  #end

  #patch do
    # Makefile.target: set icon for binary file on Mac OS X
  #  url "https://gitlab.com/qemu-project/qemu/-/commit/4e34017c21485e5606beda7e6218c36d3568b363.diff"
  #  sha256 "f0efe180897f9abbecab4a52411f1ed36f751cdf6dcc8f5863e3e03cbdac8df7"
  #end

  #patch do
    # tcg/i386: Use byte form of xgetbv instruction
    #url "https://gitlab.com/qemu-project/qemu/-/commit/1019242af11400252f6735ca71a35f81ac23a66d.diff"
  #end

  def install
    ENV["LIBTOOL"] = "glibtool"
    # Need to tell ar(1) to generate a table of contents otherwise ld(1) errors
    # ld: in dtc/libfdt/libfdt.a, archive has no table of contents
    ENV["ARFLAGS"] = "srv" if MacOS.version == :leopard
    #ENV.append_to_cflags "-D__STDC_CONSTANT_MACROS"

    if MacOS.version < :leopard
      # Needed for certain stdint macros on 10.4
      ENV.append_to_cflags "-D__STDC_CONSTANT_MACROS"

      # Make 3.80 does not support the `or` operator and has trouble evaluating `unnest-vars`
      # See https://github.com/mistydemeo/tigerbrew/pull/496
      ENV["MAKE"] = make_path
    end

    # vhost-crypto needs O_CLOEXEC support from OS
    args = %W[
      --prefix=#{prefix}
      --cc=#{ENV.cc}
      --host-cc=#{ENV.cc}
      --disable-vnc-sasl
      --enable-debug
      --target-list=i386-softmmu
      --disable-vhost-crypto
      --disable-capstone
      --disable-sdl
      --disable-gtk
      --disable-opengl
      --enable-bzip2
      --enable-hvf
      --enable-curses
      --disable-curl
      --disable-attr
      --disable-vde
      --disable-brlapi
      --disable-cap-ng
      --disable-spice
      --disable-libiscsi
      --disable-rbd
      --disable-smartcard
      --disable-libusb
      --disable-usb-redir
      --disable-seccomp
      --disable-linux-aio
      --disable-glusterfs
      --disable-rdma
      --disable-libssh
      --disable-gnutls
      --disable-gcrypt
      --disable-nettle
      --disable-numa
      --disable-xen
      --enable-tools
      --disable-bochs
      --disable-lzo
      --disable-parallels
      --disable-live-block-migration
      --disable-hax
    ]
      # --enable-bochs
      # --enable-cloop
      # --enable-dmg
      # --enable-qcow1
      # --enable-qed
      # --enable-tools
      # --enable-parallels
      # --enable-vdi
      # --enable-virtfs
      # --enable-vvfat
      # --enable-snappy
      # --enable-lzo
      # --enable-lzfse
      # --enable-slirp

    # Cocoa UI uses features that require 10.5 or newer
    if MacOS.version > :tiger
      #args << "--enable-cocoa"
      args << "--disable-cocoa"
    else
      args << "--disable-cocoa"
    end

    # qemu will try to build 64-bit on 64-bit hardware, but we might not want that
    args << "--cpu=#{Hardware::CPU.arch_32_bit}" unless MacOS.prefer_64_bit?
    args << (build.with?("sdl") ? "--enable-sdl" : "--disable-sdl")
    args << (build.with?("vde") ? "--enable-vde" : "--disable-vde")
    args << (build.with?("gtk+") ? "--enable-gtk" : "--disable-gtk")
    #args << (build.with?("libssh2") ? "--enable-libssh2" : "--disable-libssh2")

    system "./configure", *args
    make "V=1", "install"
  end

  test do
    resource("armtest").stage testpath
    assert_match /file format: raw/, shell_output("#{bin}/qemu-img info arm_root.img")
  end
    # block/raw-posix.c: Make physical devices usable in QEMU under Mac OS X host
    # https://gitlab.com/qemu-project/qemu/-/commit/d0855f1235ed203700a3a24fc7e138490c272117
    # block/raw-posix.c: Make GetBSDPath() handle caching options
    # https://gitlab.com/qemu-project/qemu/-/commit/98caa5bc0083ed4fe4833addd3078b56ce2f6cfa

    # Revert "Use O_CLOEXEC in qcrypto_random_init" since Leopard & Tiger lack support.
    # https://gitlab.com/qemu-project/qemu/-/commit/e9979ca64e5e4a150f5346de3982f02f54c41076
    # clock_gettime(3) first appeared in OS X 10.12, CLOCK_MONOTONIC is not defined.
    # Revert "qemu-io-cmds: use clock_gettime for benchmarking"
    # https://gitlab.com/qemu-project/qemu/-/commit/50290c002c045280f8defad911901e16bfb52884
    # Partially revert "usb-mtp: use O_NOFOLLOW and O_CLOEXEC." since Leopard & Tiger lack
    # O_CLOEXEC and fdopendir(3). CVE-2018-16872
    # https://gitlab.com/qemu-project/qemu/-/commit/bab9df35ce73d1c8e19a37e2737717ea1c984dc1
    # Revert "nbd/server: Avoid long error message assertions CVE-2020-10761" lack of strnlen(3)
    # https://gitlab.com/qemu-project/qemu/-/commit/5c4fe018c025740fef4a0a4421e8162db0c3eefd
    # Revert "migration: Use strnlen() for fixed-size string" lack of strnlen(3)
    # Legacy mktemp(1) expect's to be guided via flags or TMPDIR.
    # Revert "util: add cacheinfo" since it breaks startup on PowerPC & i386
    # Assertion failed: ((isize & (isize - 1)) == 0), function init_cache_info, file util/cacheinfo.c, line 188.
    # https://gitlab.com/qemu-project/qemu/-/commit/b255b2c8a5484742606e8760870ba3e14d0c9605
    # qemu_dcache_linesize & qemu_dcache_linesize_log are gone.
    patch :p0, :DATA
end
__END__
--- crypto/random-platform.c.orig	2023-08-17 01:34:15.000000000 +0100
+++ crypto/random-platform.c	2023-08-17 01:34:41.000000000 +0100
@@ -52,9 +52,9 @@
     }
     /* Fall through to /dev/urandom case.  */
 # endif
-    fd = open("/dev/urandom", O_RDONLY | O_CLOEXEC);
+    fd = open("/dev/urandom", O_RDONLY);
     if (fd == -1 && errno == ENOENT) {
-        fd = open("/dev/random", O_RDONLY | O_CLOEXEC);
+        fd = open("/dev/random", O_RDONLY);
     }
     if (fd < 0) {
         error_setg_errno(errp, errno, "No /dev/urandom or /dev/random");
--- util/qemu-timer-common.c.orig	2023-08-17 02:01:21.000000000 +0100
+++ util/qemu-timer-common.c	2023-08-17 02:03:05.000000000 +0100
@@ -49,11 +49,12 @@
 
 static void __attribute__((constructor)) init_get_clock(void)
 {
-    struct timespec ts;
-
     use_rt_clock = 0;
+#ifdef CLOCK_MONOTONIC
+    struct timespec ts;
     if (clock_gettime(CLOCK_MONOTONIC, &ts) == 0) {
         use_rt_clock = 1;
     }
+#endif
 }
 #endif
--- include/qemu/timer.h.orig	2023-08-17 01:59:32.000000000 +0100
+++ include/qemu/timer.h	2023-08-17 02:00:37.000000000 +0100
@@ -838,11 +838,14 @@
 
 static inline int64_t get_clock(void)
 {
+#ifdef CLOCK_MONOTONIC
     if (use_rt_clock) {
         struct timespec ts;
         clock_gettime(CLOCK_MONOTONIC, &ts);
         return ts.tv_sec * 1000000000LL + ts.tv_nsec;
-    } else {
+    } else
+#endif
+    {
         /* XXX: using gettimeofday leads to problems if the date
            changes, so it should be avoided. */
         return get_clock_realtime();

--- util/drm.c.orig	2023-08-17 02:39:51.000000000 +0100
+++ util/drm.c	2023-08-17 02:40:06.000000000 +0100
@@ -29,7 +29,7 @@
     char *p;
 
     if (rendernode) {
-        return open(rendernode, O_RDWR | O_CLOEXEC | O_NOCTTY | O_NONBLOCK);
+        return open(rendernode, O_RDWR | O_NOCTTY | O_NONBLOCK);
     }
 
     dir = opendir("/dev/dri");
@@ -45,7 +45,7 @@
 
         p = g_strdup_printf("/dev/dri/%s", e->d_name);
 
-        r = open(p, O_RDWR | O_CLOEXEC | O_NOCTTY | O_NONBLOCK);
+        r = open(p, O_RDWR | O_NOCTTY | O_NONBLOCK);
         if (r < 0) {
             g_free(p);
             continue;

--- qemu-io-cmds.c.orig	2020-08-11 20:17:15.000000000 +0100
+++ qemu-io-cmds.c	2023-08-17 03:02:19.000000000 +0100
@@ -248,21 +248,20 @@
 
 
 
-static struct timespec tsub(struct timespec t1, struct timespec t2)
+static struct timeval tsub(struct timeval t1, struct timeval t2)
 {
-    t1.tv_nsec -= t2.tv_nsec;
-    if (t1.tv_nsec < 0) {
-        t1.tv_nsec += NANOSECONDS_PER_SECOND;
+    t1.tv_usec -= t2.tv_usec;
+    if (t1.tv_usec < 0) {
+        t1.tv_usec += 1000000;
         t1.tv_sec--;
     }
     t1.tv_sec -= t2.tv_sec;
     return t1;
 }
 
-static double tdiv(double value, struct timespec tv)
+static double tdiv(double value, struct timeval tv)
 {
-    double seconds = tv.tv_sec + (tv.tv_nsec / 1e9);
-    return value / seconds;
+    return value / ((double)tv.tv_sec + ((double)tv.tv_usec / 1000000.0));
 }
 
 #define HOURS(sec)      ((sec) / (60 * 60))
@@ -275,27 +274,29 @@
     VERBOSE_FIXED_TIME  = 0x2,
 };
 
-static void timestr(struct timespec *tv, char *ts, size_t size, int format)
+static void timestr(struct timeval *tv, char *ts, size_t size, int format)
 {
-    double frac_sec = tv->tv_nsec / 1e9;
+    double usec = (double)tv->tv_usec / 1000000.0;
 
     if (format & TERSE_FIXED_TIME) {
         if (!HOURS(tv->tv_sec)) {
-            snprintf(ts, size, "%u:%05.2f",
-                     (unsigned int) MINUTES(tv->tv_sec),
-                     SECONDS(tv->tv_sec) + frac_sec);
+            snprintf(ts, size, "%u:%02u.%02u",
+                    (unsigned int) MINUTES(tv->tv_sec),
+                    (unsigned int) SECONDS(tv->tv_sec),
+                    (unsigned int) (usec * 100));
             return;
         }
         format |= VERBOSE_FIXED_TIME; /* fallback if hours needed */
     }
 
     if ((format & VERBOSE_FIXED_TIME) || tv->tv_sec) {
-        snprintf(ts, size, "%u:%02u:%05.2f",
+        snprintf(ts, size, "%u:%02u:%02u.%02u",
                 (unsigned int) HOURS(tv->tv_sec),
                 (unsigned int) MINUTES(tv->tv_sec),
-                 SECONDS(tv->tv_sec) + frac_sec);
+                (unsigned int) SECONDS(tv->tv_sec),
+                (unsigned int) (usec * 100));
     } else {
-        snprintf(ts, size, "%05.2f sec", frac_sec);
+        snprintf(ts, size, "0.%04u sec", (unsigned int) (usec * 10000));
     }
 }
 
@@ -452,7 +453,7 @@
     }
 }
 
-static void print_report(const char *op, struct timespec *t, int64_t offset,
+static void print_report(const char *op, struct timeval *t, int64_t offset,
                          int64_t count, int64_t total, int cnt, bool Cflag)
 {
     char s1[64], s2[64], ts[64];
@@ -725,7 +726,7 @@
 
 static int read_f(BlockBackend *blk, int argc, char **argv)
 {
-    struct timespec t1, t2;
+    struct timeval t1, t2;
     bool Cflag = false, qflag = false, vflag = false;
     bool Pflag = false, sflag = false, lflag = false, bflag = false;
     int c, cnt, ret;
@@ -834,13 +835,13 @@
 
     buf = qemu_io_alloc(blk, count, 0xab);
 
-    clock_gettime(CLOCK_MONOTONIC, &t1);
+    gettimeofday(&t1, NULL);
     if (bflag) {
         ret = do_load_vmstate(blk, buf, offset, count, &total);
     } else {
         ret = do_pread(blk, buf, offset, count, &total);
     }
-    clock_gettime(CLOCK_MONOTONIC, &t2);
+    gettimeofday(&t2, NULL);
 
     if (ret < 0) {
         printf("read failed: %s\n", strerror(-ret));
@@ -912,7 +913,7 @@
 
 static int readv_f(BlockBackend *blk, int argc, char **argv)
 {
-    struct timespec t1, t2;
+    struct timeval t1, t2;
     bool Cflag = false, qflag = false, vflag = false;
     int c, cnt, ret;
     char *buf;
@@ -967,9 +968,9 @@
         return -EINVAL;
     }
 
-    clock_gettime(CLOCK_MONOTONIC, &t1);
+    gettimeofday(&t1, NULL);
     ret = do_aio_readv(blk, &qiov, offset, &total);
-    clock_gettime(CLOCK_MONOTONIC, &t2);
+    gettimeofday(&t2, NULL);
 
     if (ret < 0) {
         printf("readv failed: %s\n", strerror(-ret));
@@ -1049,7 +1050,7 @@
 
 static int write_f(BlockBackend *blk, int argc, char **argv)
 {
-    struct timespec t1, t2;
+    struct timeval t1, t2;
     bool Cflag = false, qflag = false, bflag = false;
     bool Pflag = false, zflag = false, cflag = false, sflag = false;
     int flags = 0;
@@ -1181,7 +1182,7 @@
         }
     }
 
-    clock_gettime(CLOCK_MONOTONIC, &t1);
+    gettimeofday(&t1, NULL);
     if (bflag) {
         ret = do_save_vmstate(blk, buf, offset, count, &total);
     } else if (zflag) {
@@ -1191,7 +1192,7 @@
     } else {
         ret = do_pwrite(blk, buf, offset, count, flags, &total);
     }
-    clock_gettime(CLOCK_MONOTONIC, &t2);
+    gettimeofday(&t2, NULL);
 
     if (ret < 0) {
         printf("write failed: %s\n", strerror(-ret));
@@ -1250,7 +1251,7 @@
 
 static int writev_f(BlockBackend *blk, int argc, char **argv)
 {
-    struct timespec t1, t2;
+    struct timeval t1, t2;
     bool Cflag = false, qflag = false;
     int flags = 0;
     int c, cnt, ret;
@@ -1303,9 +1304,9 @@
         return -EINVAL;
     }
 
-    clock_gettime(CLOCK_MONOTONIC, &t1);
+    gettimeofday(&t1, NULL);
     ret = do_aio_writev(blk, &qiov, offset, flags, &total);
-    clock_gettime(CLOCK_MONOTONIC, &t2);
+    gettimeofday(&t2, NULL);
 
     if (ret < 0) {
         printf("writev failed: %s\n", strerror(-ret));
@@ -1340,15 +1341,15 @@
     bool zflag;
     BlockAcctCookie acct;
     int pattern;
-    struct timespec t1;
+    struct timeval t1;
 };
 
 static void aio_write_done(void *opaque, int ret)
 {
     struct aio_ctx *ctx = opaque;
-    struct timespec t2;
+    struct timeval t2;
 
-    clock_gettime(CLOCK_MONOTONIC, &t2);
+    gettimeofday(&t2, NULL);
 
 
     if (ret < 0) {
@@ -1378,9 +1379,9 @@
 static void aio_read_done(void *opaque, int ret)
 {
     struct aio_ctx *ctx = opaque;
-    struct timespec t2;
+    struct timeval t2;
 
-    clock_gettime(CLOCK_MONOTONIC, &t2);
+    gettimeofday(&t2, NULL);
 
     if (ret < 0) {
         printf("readv failed: %s\n", strerror(-ret));
@@ -1515,7 +1516,7 @@
         return -EINVAL;
     }
 
-    clock_gettime(CLOCK_MONOTONIC, &ctx->t1);
+    gettimeofday(&ctx->t1, NULL);
     block_acct_start(blk_get_stats(blk), &ctx->acct, ctx->qiov.size,
                      BLOCK_ACCT_READ);
     blk_aio_preadv(blk, ctx->offset, &ctx->qiov, 0, aio_read_done, ctx);
@@ -1660,7 +1661,7 @@
             return -EINVAL;
         }
 
-        clock_gettime(CLOCK_MONOTONIC, &ctx->t1);
+        gettimeofday(&ctx->t1, NULL);
         block_acct_start(blk_get_stats(blk), &ctx->acct, ctx->qiov.size,
                          BLOCK_ACCT_WRITE);
 
@@ -1841,7 +1842,7 @@
 
 static int discard_f(BlockBackend *blk, int argc, char **argv)
 {
-    struct timespec t1, t2;
+    struct timeval t1, t2;
     bool Cflag = false, qflag = false;
     int c, ret;
     int64_t offset, bytes;
@@ -1882,9 +1883,9 @@
         return -EINVAL;
     }
 
-    clock_gettime(CLOCK_MONOTONIC, &t1);
+    gettimeofday(&t1, NULL);
     ret = blk_pdiscard(blk, offset, bytes);
-    clock_gettime(CLOCK_MONOTONIC, &t2);
+    gettimeofday(&t2, NULL);
 
     if (ret < 0) {
         printf("discard failed: %s\n", strerror(-ret));
--- hw/usb/dev-mtp.c.orig	2020-08-11 20:17:15.000000000 +0100
+++ hw/usb/dev-mtp.c	2023-08-17 11:36:16.000000000 +0100
@@ -617,13 +617,8 @@
     }
     o->have_children = true;
 
-    fd = open(o->path, O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
-    if (fd < 0) {
-        return;
-    }
-    dir = fdopendir(fd);
+    dir = opendir(o->path);
     if (!dir) {
-        close(fd);
         return;
     }
 
@@ -975,7 +970,7 @@
 
     trace_usb_mtp_op_get_object(s->dev.addr, o->handle, o->path);
 
-    d->fd = open(o->path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
+    d->fd = open(o->path, O_RDONLY);
     if (d->fd == -1) {
         usb_mtp_data_free(d);
         return NULL;
@@ -999,7 +994,7 @@
                                         c->argv[1], c->argv[2]);
 
     d = usb_mtp_data_alloc(c);
-    d->fd = open(o->path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
+    d->fd = open(o->path, O_RDONLY);
     if (d->fd == -1) {
         usb_mtp_data_free(d);
         return NULL;
@@ -1636,7 +1631,7 @@
             }
 
             d->fd = open(path, O_CREAT | O_WRONLY |
-                         O_CLOEXEC | O_NOFOLLOW, mask);
+                         O_NOFOLLOW, mask);
             if (d->fd == -1) {
                 ret = 1;
                 goto done;

--- nbd/server.c.orig	2020-08-11 20:17:15.000000000 +0100
+++ nbd/server.c	2023-08-17 12:08:55.000000000 +0100
@@ -220,7 +220,7 @@
 
     msg = g_strdup_vprintf(fmt, va);
     len = strlen(msg);
-    assert(len < NBD_MAX_STRING_SIZE);
+    assert(len < 4096);
     trace_nbd_negotiate_send_rep_err(msg);
     ret = nbd_negotiate_send_rep_len(client, type, len, errp);
     if (ret < 0) {
@@ -234,19 +234,6 @@
     return 0;
 }
 
-/*
- * Return a malloc'd copy of @name suitable for use in an error reply.
- */
-static char *
-nbd_sanitize_name(const char *name)
-{
-    if (strnlen(name, 80) < 80) {
-        return g_strdup(name);
-    }
-    /* XXX Should we also try to sanitize any control characters? */
-    return g_strdup_printf("%.80s...", name);
-}
-
 /* Send an error reply.
  * Return -errno on error, 0 on success. */
 static int GCC_FMT_ATTR(4, 5)
@@ -613,11 +600,9 @@
 
     exp = nbd_export_find(name);
     if (!exp) {
-        g_autofree char *sane_name = nbd_sanitize_name(name);
-
         return nbd_negotiate_send_rep_err(client, NBD_REP_ERR_UNKNOWN,
                                           errp, "export '%s' not present",
-                                          sane_name);
+                                          name);
     }
 
     /* Don't bother sending NBD_INFO_NAME unless client requested it */
@@ -1015,10 +1000,8 @@
 
     meta->exp = nbd_export_find(export_name);
     if (meta->exp == NULL) {
-        g_autofree char *sane_name = nbd_sanitize_name(export_name);
-
         return nbd_opt_drop(client, NBD_REP_ERR_UNKNOWN, errp,
-                            "export '%s' not present", sane_name);
+                            "export '%s' not present", export_name);
     }
 
     ret = nbd_opt_read(client, &nb_queries, sizeof(nb_queries), errp);
--- tests/qemu-iotests/143.orig	2020-08-11 20:17:15.000000000 +0100
+++ tests/qemu-iotests/143	2023-08-17 12:08:55.000000000 +0100
@@ -58,10 +58,6 @@
 $QEMU_IO_PROG -f raw -c quit \
     "nbd+unix:///no_such_export?socket=$SOCK_DIR/nbd" 2>&1 \
     | _filter_qemu_io | _filter_nbd
-# Likewise, with longest possible name permitted in NBD protocol
-$QEMU_IO_PROG -f raw -c quit \
-    "nbd+unix:///$(printf %4096d 1 | tr ' ' a)?socket=$SOCK_DIR/nbd" 2>&1 \
-    | _filter_qemu_io | _filter_nbd | sed 's/aaaa*aa/aa--aa/'
 
 _send_qemu_cmd $QEMU_HANDLE \
     "{ 'execute': 'quit' }" \

--- tests/qemu-iotests/143.out.orig	2020-08-11 20:17:15.000000000 +0100
+++ tests/qemu-iotests/143.out	2023-08-17 12:08:55.000000000 +0100
@@ -5,8 +5,6 @@
 {"return": {}}
 qemu-io: can't open device nbd+unix:///no_such_export?socket=SOCK_DIR/nbd: Requested export not available
 server reported: export 'no_such_export' not present
-qemu-io: can't open device nbd+unix:///aa--aa1?socket=SOCK_DIR/nbd: Requested export not available
-server reported: export 'aa--aa...' not present
 { 'execute': 'quit' }
 {"return": {}}
 {"timestamp": {"seconds":  TIMESTAMP, "microseconds":  TIMESTAMP}, "event": "SHUTDOWN", "data": {"guest": false, "reason": "host-qmp-quit"}}

--- migration/global_state.c.orig	2020-08-11 20:17:14.000000000 +0100
+++ migration/global_state.c	2023-08-17 12:30:21.000000000 +0100
@@ -90,17 +90,6 @@
     s->received = true;
     trace_migrate_global_state_post_load(runstate);
 
-    if (strnlen((char *)s->runstate,
-                sizeof(s->runstate)) == sizeof(s->runstate)) {
-        /*
-         * This condition should never happen during migration, because
-         * all runstate names are shorter than 100 bytes (the size of
-         * s->runstate). However, a malicious stream could overflow
-         * the qapi_enum_parse() call, so we force the last character
-         * to a NUL byte.
-         */
-        s->runstate[sizeof(s->runstate) - 1] = '\0';
-    }
     r = qapi_enum_parse(&RunState_lookup, runstate, -1, &local_err);
 
     if (r == -1) {
@@ -119,8 +108,7 @@
     GlobalState *s = opaque;
 
     trace_migrate_global_state_pre_save((char *)s->runstate);
-    s->size = strnlen((char *)s->runstate, sizeof(s->runstate)) + 1;
-    assert(s->size <= sizeof(s->runstate));
+    s->size = strlen((char *)s->runstate) + 1;
 
     return 0;
 }

--- Makefile.orig	2023-08-17 15:23:02.000000000 +0100
+++ Makefile	2023-08-17 15:24:22.000000000 +0100
@@ -962,7 +962,7 @@
 endif
 ifneq ($(DESCS),)
 	$(INSTALL_DIR) "$(DESTDIR)$(qemu_datadir)/firmware"
-	set -e; tmpf=$$(mktemp); trap 'rm -f -- "$$tmpf"' EXIT; \
+	set -e; tmpf=$$(mktemp -t /tmp); trap 'rm -f -- "$$tmpf"' EXIT; \
 	for x in $(DESCS); do \
 		sed -e 's,@DATADIR@,$(qemu_datadir),' \
 			"$(SRC_PATH)/pc-bios/descriptors/$$x" > "$$tmpf"; \

--- include/qemu/osdep.h.orig	2023-08-17 21:46:08.000000000 +0100
+++ include/qemu/osdep.h	2023-08-17 21:50:55.000000000 +0100
@@ -641,11 +641,6 @@
 extern uintptr_t qemu_real_host_page_size;
 extern intptr_t qemu_real_host_page_mask;
 
-extern int qemu_icache_linesize;
-extern int qemu_icache_linesize_log;
-extern int qemu_dcache_linesize;
-extern int qemu_dcache_linesize_log;
-
 /*
  * After using getopt or getopt_long, if you need to parse another set
  * of options, then you must reset optind.  Unfortunately the way to

--- tcg/ppc/tcg-target.inc.c.orig	2020-08-11 20:17:15.000000000 +0100
+++ tcg/ppc/tcg-target.inc.c	2023-08-17 21:46:08.000000000 +0100
@@ -3861,11 +3861,14 @@
 }
 #endif /* __ELF__ */
 
+static size_t dcache_bsize = 16;
+static size_t icache_bsize = 16;
+
 void flush_icache_range(uintptr_t start, uintptr_t stop)
 {
     uintptr_t p, start1, stop1;
-    size_t dsize = qemu_dcache_linesize;
-    size_t isize = qemu_icache_linesize;
+    size_t dsize = dcache_bsize;
+    size_t isize = icache_bsize;
 
     start1 = start & ~(dsize - 1);
     stop1 = (stop + dsize - 1) & ~(dsize - 1);
@@ -3882,3 +3885,67 @@
     asm volatile ("sync" : : : "memory");
     asm volatile ("isync" : : : "memory");
 }
+
+#if defined _AIX
+#include <sys/systemcfg.h>
+
+static void __attribute__((constructor)) tcg_cache_init(void)
+{
+    icache_bsize = _system_configuration.icache_line;
+    dcache_bsize = _system_configuration.dcache_line;
+}
+
+#elif defined __linux__
+static void __attribute__((constructor)) tcg_cache_init(void)
+{
+    unsigned long dsize = qemu_getauxval(AT_DCACHEBSIZE);
+    unsigned long isize = qemu_getauxval(AT_ICACHEBSIZE);
+
+    if (dsize == 0 || isize == 0) {
+        if (dsize == 0) {
+            fprintf(stderr, "getauxval AT_DCACHEBSIZE failed\n");
+        }
+        if (isize == 0) {
+            fprintf(stderr, "getauxval AT_ICACHEBSIZE failed\n");
+        }
+        exit(1);
+    }
+    dcache_bsize = dsize;
+    icache_bsize = isize;
+}
+
+#elif defined __APPLE__
+#include <sys/sysctl.h>
+
+static void __attribute__((constructor)) tcg_cache_init(void)
+{
+    size_t len;
+    unsigned cacheline;
+    int name[2] = { CTL_HW, HW_CACHELINE };
+
+    len = sizeof(cacheline);
+    if (sysctl(name, 2, &cacheline, &len, NULL, 0)) {
+        perror("sysctl CTL_HW HW_CACHELINE failed");
+        exit(1);
+    }
+    dcache_bsize = cacheline;
+    icache_bsize = cacheline;
+}
+
+#elif defined(__FreeBSD__) || defined(__FreeBSD_kernel__)
+#include <sys/sysctl.h>
+
+static void __attribute__((constructor)) tcg_cache_init(void)
+{
+    size_t len = 4;
+    unsigned cacheline;
+
+    if (sysctlbyname ("machdep.cacheline_size", &cacheline, &len, NULL, 0)) {
+        fprintf(stderr, "sysctlbyname machdep.cacheline_size failed: %s\n",
+                strerror(errno));
+        exit(1);
+    }
+    dcache_bsize = cacheline;
+    icache_bsize = cacheline;
+}
+#endif

--- util/Makefile.objs.orig	2023-08-17 21:46:08.000000000 +0100
+++ util/Makefile.objs	2023-08-17 21:52:28.000000000 +0100
@@ -19,7 +19,6 @@
 util-obj-y += host-utils.o
 util-obj-y += bitmap.o bitops.o
 util-obj-y += fifo8.o
-util-obj-y += cacheinfo.o
 util-obj-y += error.o qemu-error.o
 util-obj-y += qemu-print.o
 util-obj-y += id.o

--- util/atomic64.c.orig	2023-08-17 22:09:09.000000000 +0100
+++ util/atomic64.c	2023-08-17 22:24:53.000000000 +0100
@@ -33,7 +33,7 @@
     uintptr_t a = (uintptr_t)addr;
     uintptr_t idx;
 
-    idx = a >> qemu_dcache_linesize_log;
+    idx = a >> ctz32(dcache_bsize);
     idx ^= (idx >> 8) ^ (idx >> 16);
     idx &= NR_LOCKS - 1;
     return lock_array + idx * lock_size;
@@ -73,8 +73,8 @@
 {
     int i;
 
-    lock_size = ROUND_UP(sizeof(QemuSpin), qemu_dcache_linesize);
-    lock_array = qemu_memalign(qemu_dcache_linesize, lock_size * NR_LOCKS);
+    lock_size = ROUND_UP(sizeof(QemuSpin), dcache_bsize);
+    lock_array = qemu_memalign(dcache_bsize, lock_size * NR_LOCKS);
     for (i = 0; i < NR_LOCKS; i++) {
         QemuSpin *lock = lock_array + i * lock_size;
 


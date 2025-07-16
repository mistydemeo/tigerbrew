class Libiscsi < Formula
  desc "Client library and utilities for iscsi"
  homepage "https://github.com/sahlberg/libiscsi"
  url "https://github.com/sahlberg/libiscsi/archive/refs/tags/1.20.2.tar.gz"
  sha256 "2b2a773ea0d3a708c1cafe61bbee780325fb1aafec6477f17d3f403e8732c9bf"
  license all_of: [:public_domain, "LGPL-2.1-or-later", "GPL-2.0-or-later"]
  head "https://github.com/sahlberg/libiscsi.git"

  bottle do
    cellar :any
  end

  # Skip warning flags which are not supported with GCC 4.0
  # Only show time if clock_gettime(3) is available
  # https://github.com/sahlberg/libiscsi/pull/454
  patch :p0, :DATA

  option "with-test-tool", "Build test-tool (to test a remote server)"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "cunit" if build.with? "test-tool"

  def install
    # Install the examples which are normally set for noinst
    inreplace "examples/Makefile.am", "noinst_PROGRAMS =", "bin_PROGRAMS ="
    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
__END__
--- configure.ac.orig	2025-07-16 15:36:55.000000000 +0100
+++ configure.ac	2025-07-16 15:37:22.000000000 +0100
@@ -32,8 +33,7 @@
               [Disables building with -Werror by default])])
 
 if test "$ac_cv_c_compiler_gnu" = yes; then
-   WARN_CFLAGS="-Wall -W -Wshadow -Wstrict-prototypes -Wpointer-arith -Wcast-align -Wcast-qual -Wvla"
-   WARN_CFLAGS="$WARN_CFLAGS -Wno-unknown-warning-option -Wno-stringop-truncation"
+   WARN_CFLAGS="-Wall -W -Wshadow -Wstrict-prototypes -Wpointer-arith -Wcast-align -Wcast-qual"
    WARN_CFLAGS="$WARN_CFLAGS -Wno-unused-parameter"
    if test "x$enable_werror" != "xno"; then
        WARN_CFLAGS="$WARN_CFLAGS -Werror"
--- examples/iscsi-dd.c.orig	2025-07-16 15:42:31.000000000 +0100
+++ examples/iscsi-dd.c	2025-07-16 15:45:52.000000000 +0100
@@ -557,6 +557,7 @@
 	exit(status);
 }
 
+#if HAVE_CLOCK_GETTIME
 static void show_perf(struct timespec *start_time,
 		      struct timespec *end_time,
 		      uint64_t num_blocks,
@@ -576,6 +577,7 @@
 	printf("\r%"PRIu64" blocks (%"PRIu64" sized) copied in %g seconds,"
 	   " %g%c/s.\n", num_blocks, block_size, elapsed, ubytes_per_sec, u[i]);
 }
+#endif
 
 static void iscsi_endpoint_init(const char *url,
 				const char *usage,
@@ -635,7 +637,9 @@
 	struct client client;
 	struct timespec start_time;
 	struct timespec end_time;
+#if HAVE_CLOCK_GETTIME
 	int gettime_ret;
+#endif
 	static struct option long_options[] = {
 		{"dst",            required_argument,    NULL,        'd'},
 		{"src",            required_argument,    NULL,        's'},
@@ -719,10 +723,12 @@
 		exit(10);
 	}
 
+#if HAVE_CLOCK_GETTIME
 	gettime_ret = clock_gettime(CLOCK_MONOTONIC, &start_time);
 	if (gettime_ret < 0) {
 		fprintf(stderr, "clock_gettime(CLOCK_MONOTONIC) failed\n");
 	}
+#endif
 
 	if (client.use_xcopy) {
 		fill_xcopy_queue(&client);
@@ -755,6 +761,7 @@
 		}
 	}
 
+#if HAVE_CLOCK_GETTIME
 	if (gettime_ret == 0) {
 		/* start_time is valid, so dump perf with a valid end_time */
 		gettime_ret = clock_gettime(CLOCK_MONOTONIC, &end_time);
@@ -763,6 +770,7 @@
 				  client.src.blocksize);
 		}
 	}
+#endif
 
 	iscsi_logout_sync(client.src.iscsi);
 	iscsi_destroy_context(client.src.iscsi);

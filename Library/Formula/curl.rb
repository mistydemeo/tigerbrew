class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "https://curl.se/download/curl-8.19.0.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-8_19_0/curl-8.19.0.tar.bz2"
  sha256 "eba3230c1b659211a7afa0fbf475978cbf99c412e4d72d9aa92d020c460742d4"
  license "curl"

  bottle do
    cellar :any
  end

  # pragma GCC diagnostic not allowed inside functions prior to GCC 4.6
  # https://github.com/curl/curl/commit/578ee6b79b240a0b41de039913357b100e19283e
  patch :p1, :DATA

  keg_only :provided_by_osx

  option "with-rtmpdump", "Build with RTMP support"
  option "with-libssh2", "Build with scp and sftp support"
  option "with-c-ares", "Build with C-Ares async DNS support"
  option "with-gssapi", "Build with GSSAPI/Kerberos authentication support."
  option "with-libressl", "Build with LibreSSL instead of Secure Transport or OpenSSL"

  deprecated_option "with-rtmp" => "with-rtmpdump"
  deprecated_option "with-ssh" => "with-libssh2"
  deprecated_option "with-ares" => "with-c-ares"

  if (build.without?("libressl"))
    depends_on "openssl3"
  end

  depends_on "pkg-config" => :build
  depends_on "rtmpdump" => :optional
  depends_on "libssh2" => :optional
  depends_on "c-ares" => :optional
  depends_on "libressl" => :optional
  depends_on "libnghttp2"
  depends_on "libpsl"
  depends_on "libidn2"
  depends_on "zlib"

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-zlib=#{Formula["zlib"].opt_prefix}
    ]

    # cURL has a new firm desire to find ssl with PKG_CONFIG_PATH instead of using
    # "--with-ssl" any more. "when possible, set the PKG_CONFIG_PATH environment
    # variable instead of using this option". Multi-SSL choice breaks w/o using it.
    if build.with? "libressl"
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["libressl"].opt_lib}/pkgconfig"
      args << "--with-ssl=#{Formula["libressl"].opt_prefix}"
      args << "--with-ca-bundle=#{etc}/libressl/cert.pem"
    else
      ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["openssl3"].opt_lib}/pkgconfig"
      args << "--with-ssl=#{Formula["openssl3"].opt_prefix}"
      args << "--with-ca-bundle=#{etc}/openssl@3/cert.pem"
    end

    args << (build.with?("libssh2") ? "--with-libssh2" : "--without-libssh2")
    args << (build.with?("gssapi") ? "--with-gssapi" : "--without-gssapi")
    args << (build.with?("rtmpdump") ? "--with-librtmp" : "--without-librtmp")

    if build.with? "c-ares"
      args << "--enable-ares=#{Formula["c-ares"].opt_prefix}"
    else
      args << "--disable-ares"
    end

    system "./configure", *args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "scripts/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    # so mk-ca-bundle can find it
    ENV.prepend_path "PATH", Formula["curl"].opt_bin
    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert File.exist?("test.pem")
    assert File.exist?("certdata.txt")
  end

end
__END__
diff --git a/CMake/PickyWarnings.cmake b/CMake/PickyWarnings.cmake
index 1b67b0be7c4e..4e22d8b45ca4 100644
--- a/CMake/PickyWarnings.cmake
+++ b/CMake/PickyWarnings.cmake
@@ -60,7 +60,9 @@ elseif(BORLAND)
 endif()
 
 if(PICKY_COMPILER)
-  if(CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_C_COMPILER_ID MATCHES "Clang")
+  # Leave disabled for GCC <4.6, because they lack #pragma features to silence locally.
+  if((CMAKE_C_COMPILER_ID STREQUAL "GNU" AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 4.6) OR
+     CMAKE_C_COMPILER_ID MATCHES "Clang")
 
     # https://clang.llvm.org/docs/DiagnosticsReference.html
     # https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
@@ -378,15 +380,6 @@ if(PICKY_COMPILER)
     endforeach()
 
     if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
-      if(CMAKE_C_COMPILER_VERSION VERSION_LESS 4.5)
-        # Avoid false positives
-        list(APPEND _picky "-Wno-shadow")
-        list(APPEND _picky "-Wno-unreachable-code")
-      endif()
-      if(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 4.2 AND CMAKE_C_COMPILER_VERSION VERSION_LESS 4.6)
-        # GCC <4.6 do not support #pragma to suppress warnings locally. Disable them globally instead.
-        list(APPEND _picky "-Wno-overlength-strings")
-      endif()
       if(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 4.0 AND CMAKE_C_COMPILER_VERSION VERSION_LESS 4.7)
         list(APPEND _picky "-Wno-missing-field-initializers")  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=36750
       endif()
diff --git a/docs/examples/sendrecv.c b/docs/examples/sendrecv.c
index 964fc6e0b8f3..a8d06970288d 100644
--- a/docs/examples/sendrecv.c
+++ b/docs/examples/sendrecv.c
@@ -34,7 +34,7 @@
  * warning: conversion to 'long unsigned int' from 'curl_socket_t' {aka 'int'}
  * may change the sign of the result [-Wsign-conversion]
  */
-#ifdef __GNUC__
+#ifdef __GNUC__  /* keep outside functions and without push/pop for GCC <4.6 */
 #pragma GCC diagnostic ignored "-Wsign-conversion"
 #elif defined(_MSC_VER)
 #pragma warning(disable:4127)  /* conditional expression is constant */
diff --git a/lib/content_encoding.c b/lib/content_encoding.c
index aa35da840b23..32d32241f4ea 100644
--- a/lib/content_encoding.c
+++ b/lib/content_encoding.c
@@ -31,13 +31,13 @@
 #endif
 
 #ifdef HAVE_BROTLI
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 /* Ignore -Wvla warnings in brotli headers */
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wvla"
 #endif
 #include <brotli/decode.h>
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 #pragma GCC diagnostic pop
 #endif
 #endif
diff --git a/lib/curl_gssapi.c b/lib/curl_gssapi.c
index c0eb1c4db1bc..1feb0bf88fc4 100644
--- a/lib/curl_gssapi.c
+++ b/lib/curl_gssapi.c
@@ -55,7 +55,7 @@
 #define CURL_ALIGN8
 #endif
 
-#if defined(__GNUC__) && defined(__APPLE__)
+#if defined(CURL_HAVE_DIAG) && defined(__APPLE__)
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
 #endif
@@ -441,7 +441,7 @@ void Curl_gss_log_error(struct Curl_easy *data, const char *prefix,
 }
 #endif /* CURLVERBOSE */
 
-#if defined(__GNUC__) && defined(__APPLE__)
+#if defined(CURL_HAVE_DIAG) && defined(__APPLE__)
 #pragma GCC diagnostic pop
 #endif
 
diff --git a/lib/curl_setup.h b/lib/curl_setup.h
index 4f8d65af8b5d..0765c80fc0d4 100644
--- a/lib/curl_setup.h
+++ b/lib/curl_setup.h
@@ -774,6 +774,16 @@
 #define USE_SSH
 #endif
 
+/* GCC <4.6 does not support '#pragma GCC diagnostic push' and does not support
+   'pragma GCC diagnostic' inside functions.
+   Use CURL_HAVE_DIAG to guard the above in the curl codebase, instead of
+   defined(__GNUC__) || defined(__clang__).
+ */
+#if defined(__clang__) || (defined(__GNUC__) && \
+  ((__GNUC__ > 4) || ((__GNUC__ == 4) && (__GNUC_MINOR__ >= 6))))
+#define CURL_HAVE_DIAG
+#endif
+
 /*
  * Provide a mechanism to silence picky compilers, such as gcc 4.6+.
  * Parameters should of course normally not be unused, but for example when
diff --git a/lib/curlx/snprintf.c b/lib/curlx/snprintf.c
index c7332520e7a2..911c42e6adde 100644
--- a/lib/curlx/snprintf.c
+++ b/lib/curlx/snprintf.c
@@ -34,13 +34,13 @@ void curlx_win32_snprintf(char *buf, size_t maxlen, const char *fmt, ...)
   if(!maxlen)
     return;
   va_start(ap, fmt);
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wformat-nonliteral"
 #endif
   /* !checksrc! disable BANNEDFUNC 1 */
   (void)vsnprintf(buf, maxlen, fmt, ap);
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 #pragma GCC diagnostic pop
 #endif
   buf[maxlen - 1] = 0;
diff --git a/lib/ftp.c b/lib/ftp.c
index 2597c10ccef6..08c020f65493 100644
--- a/lib/ftp.c
+++ b/lib/ftp.c
@@ -2567,7 +2567,7 @@ static CURLcode ftp_state_mdtm_resp(struct Curl_easy *data,
     /* If we asked for a time of the file and we actually got one as well,
        we "emulate" an HTTP-style header in our output. */
 
-#if defined(__GNUC__) && (defined(__DJGPP__) || defined(__AMIGA__))
+#if defined(CURL_HAVE_DIAG) && (defined(__DJGPP__) || defined(__AMIGA__))
 #pragma GCC diagnostic push
 /* 'time_t' is unsigned in MSDOS and AmigaOS. Silence:
    warning: comparison of unsigned expression in '>= 0' is always true */
@@ -2575,7 +2575,7 @@ static CURLcode ftp_state_mdtm_resp(struct Curl_easy *data,
 #endif
     if(data->req.no_body && ftpc->file &&
        data->set.get_filetime && showtime) {
-#if defined(__GNUC__) && (defined(__DJGPP__) || defined(__AMIGA__))
+#if defined(CURL_HAVE_DIAG) && (defined(__DJGPP__) || defined(__AMIGA__))
 #pragma GCC diagnostic pop
 #endif
       char headerbuf[128];
diff --git a/lib/if2ip.c b/lib/if2ip.c
index 05e3f84f4ce7..b71254ada00e 100644
--- a/lib/if2ip.c
+++ b/lib/if2ip.c
@@ -210,13 +210,13 @@ if2ip_result_t Curl_if2ip(int af,
   memcpy(req.ifr_name, interf, len + 1);
   req.ifr_addr.sa_family = AF_INET;
 
-#if defined(__GNUC__) && defined(_AIX)
+#if defined(CURL_HAVE_DIAG) && defined(_AIX)
 /* Suppress warning inside system headers */
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wshift-sign-overflow"
 #endif
   if(ioctl(dummy, SIOCGIFADDR, &req) < 0) {
-#if defined(__GNUC__) && defined(_AIX)
+#if defined(CURL_HAVE_DIAG) && defined(_AIX)
 #pragma GCC diagnostic pop
 #endif
     sclose(dummy);
diff --git a/lib/ldap.c b/lib/ldap.c
index 09eb47c81bcb..a816b1c3faee 100644
--- a/lib/ldap.c
+++ b/lib/ldap.c
@@ -27,7 +27,7 @@
 
 #if !defined(CURL_DISABLE_LDAP) && !defined(USE_OPENLDAP)
 
-#if defined(__GNUC__) && defined(__APPLE__)
+#if defined(CURL_HAVE_DIAG) && defined(__APPLE__)
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
 #endif
@@ -994,7 +994,7 @@ const struct Curl_protocol Curl_protocol_ldap = {
   ZERO_NULL,                            /* follow */
 };
 
-#if defined(__GNUC__) && defined(__APPLE__)
+#if defined(CURL_HAVE_DIAG) && defined(__APPLE__)
 #pragma GCC diagnostic pop
 #endif
 
diff --git a/lib/mprintf.c b/lib/mprintf.c
index c6a4a4942922..df9c0f4752e4 100644
--- a/lib/mprintf.c
+++ b/lib/mprintf.c
@@ -672,7 +672,7 @@ static bool out_double(void *userp,
 
   /* NOTE NOTE NOTE!! Not all sprintf implementations return number of
      output characters */
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wformat-nonliteral"
 #endif
@@ -687,7 +687,7 @@ static bool out_double(void *userp,
   /* float and double outputs do not work without snprintf support */
   work[0] = 0;
 #endif
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 #pragma GCC diagnostic pop
 #endif
   DEBUGASSERT(strlen(work) < BUFFSIZE);
diff --git a/lib/socks_gssapi.c b/lib/socks_gssapi.c
index 962fcd05b2a6..d43f44708c28 100644
--- a/lib/socks_gssapi.c
+++ b/lib/socks_gssapi.c
@@ -35,7 +35,7 @@
 #include "socks.h"
 #include "curlx/strdup.h"
 
-#if defined(__GNUC__) && defined(__APPLE__)
+#if defined(CURL_HAVE_DIAG) && defined(__APPLE__)
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
 #endif
@@ -526,7 +526,7 @@ CURLcode Curl_SOCKS5_gssapi_negotiate(struct Curl_cfilter *cf,
   return CURLE_OK;
 }
 
-#if defined(__GNUC__) && defined(__APPLE__)
+#if defined(CURL_HAVE_DIAG) && defined(__APPLE__)
 #pragma GCC diagnostic pop
 #endif
 
diff --git a/lib/vauth/krb5_gssapi.c b/lib/vauth/krb5_gssapi.c
index d6af18f40b5b..64c735be582a 100644
--- a/lib/vauth/krb5_gssapi.c
+++ b/lib/vauth/krb5_gssapi.c
@@ -33,7 +33,7 @@
 #include "curl_gssapi.h"
 #include "curl_trc.h"
 
-#if defined(__GNUC__) && defined(__APPLE__)
+#if defined(CURL_HAVE_DIAG) && defined(__APPLE__)
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
 #endif
@@ -320,7 +320,7 @@ void Curl_auth_cleanup_gssapi(struct kerberos5data *krb5)
   }
 }
 
-#if defined(__GNUC__) && defined(__APPLE__)
+#if defined(CURL_HAVE_DIAG) && defined(__APPLE__)
 #pragma GCC diagnostic pop
 #endif
 
diff --git a/lib/vauth/spnego_gssapi.c b/lib/vauth/spnego_gssapi.c
index eafc44c5918b..4dca3ac03373 100644
--- a/lib/vauth/spnego_gssapi.c
+++ b/lib/vauth/spnego_gssapi.c
@@ -32,7 +32,7 @@
 #include "curl_gssapi.h"
 #include "curl_trc.h"
 
-#if defined(__GNUC__) && defined(__APPLE__)
+#if defined(CURL_HAVE_DIAG) && defined(__APPLE__)
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
 #endif
@@ -288,7 +288,7 @@ void Curl_auth_cleanup_spnego(struct negotiatedata *nego)
   nego->havemultiplerequests = FALSE;
 }
 
-#if defined(__GNUC__) && defined(__APPLE__)
+#if defined(CURL_HAVE_DIAG) && defined(__APPLE__)
 #pragma GCC diagnostic pop
 #endif
 
diff --git a/lib/version.c b/lib/version.c
index 7ccd875dc8e3..7e54bde26da9 100644
--- a/lib/version.c
+++ b/lib/version.c
@@ -56,13 +56,13 @@
 #endif
 
 #ifdef HAVE_BROTLI
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 /* Ignore -Wvla warnings in brotli headers */
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wvla"
 #endif
 #include <brotli/decode.h>
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 #pragma GCC diagnostic pop
 #endif
 #endif
diff --git a/src/tool_cb_prg.c b/src/tool_cb_prg.c
index 6c3a366fa632..1af621dbaaa0 100644
--- a/src/tool_cb_prg.c
+++ b/src/tool_cb_prg.c
@@ -200,12 +200,12 @@ int tool_progress_cb(void *clientp,
     memset(line, '#', num);
     line[num] = '\0';
     curl_msnprintf(format, sizeof(format), "\r%%-%ds %%5.1f%%%%", barwidth);
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wformat-nonliteral"
 #endif
     curl_mfprintf(bar->out, format, line, percent);
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 #pragma GCC diagnostic pop
 #endif
   }
diff --git a/src/tool_main.c b/src/tool_main.c
index afa556ef3fca..e5e4659b1585 100644
--- a/src/tool_main.c
+++ b/src/tool_main.c
@@ -132,7 +132,7 @@ static void memory_tracking_init(void)
 ** curl tool main function.
 */
 #ifdef _UNICODE
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 /* GCC does not know about wmain() */
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wmissing-prototypes"
@@ -205,7 +205,7 @@ int main(int argc, char *argv[])
 }
 
 #ifdef _UNICODE
-#if defined(__GNUC__) || defined(__clang__)
+#ifdef CURL_HAVE_DIAG
 #pragma GCC diagnostic pop
 #endif
 #endif
diff --git a/src/tool_writeout.c b/src/tool_writeout.c
index 79e34cbc4437..994141b91486 100644
--- a/src/tool_writeout.c
+++ b/src/tool_writeout.c
@@ -580,14 +580,14 @@ static const char *outtime(const char *ptr, /* %time{ ... */
     if(!result) {
       struct tm utc;
       result = curlx_gmtime(secs, &utc);
-#ifdef __GNUC__
+#ifdef CURL_HAVE_DIAG /* includes llvm/clang, but not affected as of v22.1.0 */
 #pragma GCC diagnostic push
 #pragma GCC diagnostic ignored "-Wformat-nonliteral"
 #endif
       if(curlx_dyn_len(&format) && !result &&
          strftime(output, sizeof(output), curlx_dyn_ptr(&format), &utc))
         fputs(output, stream);
-#ifdef __GNUC__
+#ifdef CURL_HAVE_DIAG
 #pragma GCC diagnostic pop
 #endif
       curlx_dyn_free(&format);

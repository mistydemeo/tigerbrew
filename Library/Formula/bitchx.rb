class Bitchx < Formula
  desc "BitchX IRC client"
  homepage "http://bitchx.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/bitchx/ircii-pana/bitchx-1.2.1/bitchx-1.2.1.tar.gz"
  sha256 "2d270500dd42b5e2b191980d584f6587ca8a0dbda26b35ce7fadb519f53c83e2"
  revision 1

  bottle do
    sha256 "fe307bff999a81c0923462bb39abd01b2446adb3e423cb8eb47e6de304d353bc" => :tiger_altivec
  end

  depends_on "openssl"

  # array out of bounds error
  # Remove duplicate global definitions
  # https://sourceforge.net/p/bitchx/git/ci/1c6ff3088ad01a15bea50f78f1b2b468db7afae9/
  # https://sourceforge.net/p/bitchx/git/ci/4f63d4892995eec6707f194b462c9fc3184ee85d/
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/7a83dbb5d8e3a3070ff80a28d396868cdd6b23ac/bitchx/linux.patch"
    sha256 "99caa10f32bfe4727a836b8cc99ec81e3c059729e4bb90641be392f4e98255d9"
  end

  def install
    # At least on a PowerMac G5, it starves itself of resources and
    # the build fails.
    ENV.deparallelize

    plugins = %w[acro arcfour amp autocycle blowfish cavlink encrypt
                 fserv hint identd nap pkga possum qbx qmail]
    args = %W[
      --prefix=#{prefix}
      --with-ssl
      --with-plugins=#{plugins * ","}
      --enable-ipv6
      --mandir=#{man}
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    On case-sensitive filesytems, it is necessary to run `BitchX` not `bitchx`.
    For best visual appearance, your terminal emulator may need:
    * Character encoding set to Western (ISO Latin 1).
      (or a similar, compatible encoding)
    * A font capable of extended ASCII characters:
      See: https://www.google.com/search?q=perfect+dos+vga+437
    EOS
  end

  test do
    system bin/"BitchX", "-v"
  end

  # Add support for OpenSSL 1.1.0 and newer
  # Add support for Darwin
  # https://sourceforge.net/p/bitchx/git/ci/184af728c73c379d1eee57a387b6012572794fa8/
  # https://sourceforge.net/p/bitchx/patches/16/
  patch :p0, :DATA
end
__END__
--- configure.in.orig	2023-06-07 00:22:15.000000000 +0100
+++ configure.in	2023-06-07 00:21:50.000000000 +0100
@@ -566,8 +566,8 @@
 esac
 case "$with_ssl" in
     yes|check)
-      AC_CHECK_LIB([crypto], [SSLeay], [], [], [])
-      if test x"$ac_cv_lib_crypto_SSLeay" = x"yes"; then
+      AC_CHECK_LIB([crypto], [ERR_get_error], [], [], [])
+      if test x"$ac_cv_lib_crypto_ERR_get_error" = x"yes"; then
         AC_CHECK_LIB([ssl], [SSL_accept], [], [], [])
       fi
       if test x"$ac_cv_lib_ssl_SSL_accept" = x"yes"; then
--- aclocal.m4.orig	2023-06-07 00:20:16.000000000 +0100
+++ aclocal.m4	2023-06-07 00:44:19.000000000 +0100
@@ -1363,6 +1363,11 @@
         SHLIB_CFLAGS="-fPIC"
         SHLIB_LD="$CC -shared"
         ;;
+      Darwin*)
+        SHLIB_LD="$CC -dynamiclib"
+        SHLIB_SUFFIX=".dylib"
+        SHLIB_CFLAGS="-fno-common"
+        ;;
       NEXTSTEP*)
         SHLIB_LD="$CC -nostdlib -r"
         ;;
--- configure.orig	2023-06-07 00:24:49.000000000 +0100
+++ configure	2023-06-07 00:44:55.000000000 +0100
@@ -10631,9 +10631,9 @@
 case "$with_ssl" in
     yes|check)
 
-echo "$as_me:$LINENO: checking for SSLeay in -lcrypto" >&5
-echo $ECHO_N "checking for SSLeay in -lcrypto... $ECHO_C" >&6
-if test "${ac_cv_lib_crypto_SSLeay+set}" = set; then
+echo "$as_me:$LINENO: checking for ERR_get_error in -lcrypto" >&5
+echo $ECHO_N "checking for ERR_get_error in -lcrypto... $ECHO_C" >&6
+if test "${ac_cv_lib_crypto_ERR_get_error+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
 else
   ac_check_lib_save_LIBS=$LIBS
@@ -10651,11 +10651,11 @@
 #endif
 /* We use char because int might match the return type of a gcc2
    builtin and then its argument prototype would still apply.  */
-char SSLeay ();
+char ERR_get_error ();
 int
 main ()
 {
-SSLeay ();
+ERR_get_error ();
   ;
   return 0;
 }
@@ -10682,20 +10682,20 @@
   ac_status=$?
   echo "$as_me:$LINENO: \$? = $ac_status" >&5
   (exit $ac_status); }; }; then
-  ac_cv_lib_crypto_SSLeay=yes
+  ac_cv_lib_crypto_ERR_get_error=yes
 else
   echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-ac_cv_lib_crypto_SSLeay=no
+ac_cv_lib_crypto_ERR_get_error=no
 fi
 rm -f conftest.err conftest.$ac_objext \
       conftest$ac_exeext conftest.$ac_ext
 LIBS=$ac_check_lib_save_LIBS
 fi
-echo "$as_me:$LINENO: result: $ac_cv_lib_crypto_SSLeay" >&5
-echo "${ECHO_T}$ac_cv_lib_crypto_SSLeay" >&6
-if test $ac_cv_lib_crypto_SSLeay = yes; then
+echo "$as_me:$LINENO: result: $ac_cv_lib_crypto_ERR_get_error" >&5
+echo "${ECHO_T}$ac_cv_lib_crypto_ERR_get_error" >&6
+if test $ac_cv_lib_crypto_ERR_get_error = yes; then
   cat >>confdefs.h <<_ACEOF
 #define HAVE_LIBCRYPTO 1
 _ACEOF
@@ -10704,7 +10704,7 @@
 
 fi
 
-      if test x"$ac_cv_lib_crypto_SSLeay" = x"yes"; then
+      if test x"$ac_cv_lib_crypto_ERR_get_error" = x"yes"; then
 
 echo "$as_me:$LINENO: checking for SSL_accept in -lssl" >&5
 echo $ECHO_N "checking for SSL_accept in -lssl... $ECHO_C" >&6
@@ -13267,6 +13267,11 @@
         SHLIB_CFLAGS="-fPIC"
         SHLIB_LD="$CC -shared"
         ;;
+      Darwin*)
+        SHLIB_LD="$CC -dynamiclib"
+        SHLIB_SUFFIX=".dylib"
+        SHLIB_CFLAGS="-fno-common"
+        ;;
       NEXTSTEP*)
         SHLIB_LD="$CC -nostdlib -r"
         ;;
@@ -14750,6 +14755,11 @@
         SHLIB_CFLAGS="-fPIC"
         SHLIB_LD="$CC -shared"
         ;;
+      Darwin*)
+        SHLIB_LD="$CC -dynamiclib"
+        SHLIB_SUFFIX=".dylib"
+        SHLIB_CFLAGS="-fno-common"
+        ;;
       NEXTSTEP*)
         SHLIB_LD="$CC -nostdlib -r"
         ;;

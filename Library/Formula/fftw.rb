class Fftw < Formula
  desc "C routines to compute the Discrete Fourier Transform"
  homepage "http://www.fftw.org"
  url "http://www.fftw.org/fftw-3.3.10.tar.gz"
  sha256 "56c932549852cddcfafdab3820b0200c7742675be92179e59e6215b340e26467"

  bottle do
    sha256 "7bae5c73283c14c0b8a10ea46aadd6a7c572e012e729971242fa9686de650dbf" => :tiger_altivec
  end

  # Update autoconf m4 components - fixes configure with GCC 4.0.1 on Tiger
  # https://github.com/FFTW/fftw3/commit/d0ce926f1523d95daed48cd7c69572e068dbbfb3
  # Skip running configure script as part of the bootstrap process.
  patch :DATA

  option "with-fortran", "Enable Fortran bindings"
  option :universal
  option "with-mpi", "Enable MPI parallel transforms"
  option "with-openmp", "Enable OpenMP parallel transforms"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on :fortran => :optional
  depends_on :mpi => [:cc, :optional]
  needs :openmp if build.with? "openmp"

  def install
    # Build sets its own optimisation at -O3
    ENV.no_optimization
    args = ["--enable-shared",
            "--disable-debug",
            "--prefix=#{prefix}",
            "--enable-threads",
            "--disable-dependency-tracking"]
    simd_args = ["--enable-sse2"]
    simd_args << "--enable-avx" if ENV.compiler == :clang && Hardware::CPU.avx? && !build.bottle?

    args << "--disable-fortran" if build.without? "fortran"
    args << "--enable-mpi" if build.with? "mpi"
    args << "--enable-openmp" if build.with? "openmp"

    # Decide which SIMD options we need
    simd_single = []
    simd_double = []

    if Hardware.cpu_type == :intel
      # enable-sse2 and enable-avx works for both single and double precision
      simd_single = ["--enable-sse2"]
      simd_single << "--enable-avx" if ENV.compiler == :clang && Hardware::CPU.avx? && !build.bottle?
      simd_double = simd_single
    elsif Hardware::CPU.altivec? && !(build.bottle? && ARGV.bottle_arch == :g3)
      simd_single << "--enable-altivec" # altivec seems to only work with single precision
    end

    ENV.universal_binary if build.universal?

    # re-bootstrap since we made changes to build infra
    system "./bootstrap.sh"

    # single precision
    # enable-sse only works with single
    # similarly altivec only works with single precision
    system "./configure", "--enable-single",
                          *(simd_single + args)
    system "make", "install"

    # clean up so we can compile the double precision variant
    system "make", "clean"

    # double precision
    # enable-sse2 only works with double precision (default)
    system "./configure", *(simd_double + args)
    system "make", "install"

    # clean up so we can compile the long-double precision variant
    system "make", "clean"

    # long-double precision
    # no SIMD optimization available
    system "./configure", "--enable-long-double", *args
    system "make", "install"
  end

  test do
    # Adapted from the sample usage provided in the documentation:
    # http://www.fftw.org/fftw3_doc/Complex-One_002dDimensional-DFTs.html
    (testpath/"fftw.c").write <<-TEST_SCRIPT.undent
      #include <fftw3.h>
      int main(int argc, char* *argv)
      {
          fftw_complex *in, *out;
          fftw_plan p;
          long N = 1;
          in = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
          out = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
          p = fftw_plan_dft_1d(N, in, out, FFTW_FORWARD, FFTW_ESTIMATE);
          fftw_execute(p); /* repeat as needed */
          fftw_destroy_plan(p);
          fftw_free(in); fftw_free(out);
          return 0;
      }
    TEST_SCRIPT

    system ENV.cc, "-o", "fftw", "fftw.c", "-lfftw3", *ENV.cflags.to_s.split
    system "./fftw"
  end
end
__END__
diff --git a/m4/Makefile.am b/m4/Makefile.am
index 860dcf25e..dc4ddfff0 100644
--- a/m4/Makefile.am
+++ b/m4/Makefile.am
@@ -1,6 +1,7 @@
 EXTRA_DIST = acx_mpi.m4 acx_pthread.m4 ax_cc_maxopt.m4	\
-ax_check_compiler_flags.m4 ax_compiler_vendor.m4	\
-ax_gcc_aligns_stack.m4 ax_gcc_version.m4 ax_openmp.m4
+ax_check_compile_flag.m4 ax_compiler_vendor.m4	\
+ax_gcc_aligns_stack.m4 ax_gcc_version.m4 ax_openmp.m4 \
+ax_check_link_flag.m4
 
 # libtool sticks a bunch of extra .m4 files in this directory,
 # but they don't seem to be needed for the distributed tarball
diff --git a/m4/ax_cc_maxopt.m4 b/m4/ax_cc_maxopt.m4
index ca514bdf5..bdb98588b 100644
--- a/m4/ax_cc_maxopt.m4
+++ b/m4/ax_cc_maxopt.m4
@@ -14,9 +14,9 @@ dnl Note also that the flags assume that ANSI C aliasing rules are
 dnl followed by the code (e.g. for gcc's -fstrict-aliasing), and that
 dnl floating-point computations can be re-ordered as needed.
 dnl
-dnl Requires macros: AX_CHECK_COMPILER_FLAGS, AX_COMPILER_VENDOR,
+dnl Requires macros: AX_CHECK_COMPILE_FLAG, AX_COMPILER_VENDOR,
 dnl
-dnl @version 2011-06-22
+dnl @version 2023-05-14
 dnl @license GPLWithACException
 dnl @author Steven G. Johnson <stevenj@alum.mit.edu> and Matteo Frigo.
 AC_DEFUN([AX_CC_MAXOPT],
@@ -39,7 +39,7 @@ if test "x$ac_test_CFLAGS" != "xset" -a "x$ac_test_CFLAGS" != "xy"; then
     	 ;;
 
     ibm) xlc_opt="-qarch=auto -qtune=auto"
-         AX_CHECK_COMPILER_FLAGS($xlc_opt,
+         AX_CHECK_COMPILE_FLAG($xlc_opt,
          	CFLAGS="-O3 -qalias=ansi -w $xlc_opt",
                [CFLAGS="-O3 -qalias=ansi -w"])
          ;;
@@ -48,12 +48,12 @@ if test "x$ac_test_CFLAGS" != "xset" -a "x$ac_test_CFLAGS" != "xy"; then
         # Intel seems to have changed the spelling of this flag recently
         icc_ansi_alias="unknown"
 	for flag in -ansi-alias -ansi_alias; do
-	  AX_CHECK_COMPILER_FLAGS($flag, [icc_ansi_alias=$flag; break])
+	  AX_CHECK_COMPILE_FLAG($flag, [icc_ansi_alias=$flag; break])
 	done
  	if test "x$icc_ansi_alias" != xunknown; then
             CFLAGS="$CFLAGS $icc_ansi_alias"
         fi
-	AX_CHECK_COMPILER_FLAGS(-malign-double, CFLAGS="$CFLAGS -malign-double")
+	AX_CHECK_COMPILE_FLAG(-malign-double, CFLAGS="$CFLAGS -malign-double")
 	# We used to check for architecture flags here, e.g. -xHost etc.,
 	# but these flags are problematic.  On icc-12.0.0, "-mavx -xHost"
 	# overrides -mavx with -xHost, generating SSE2 code instead of AVX
@@ -63,8 +63,8 @@ if test "x$ac_test_CFLAGS" != "xset" -a "x$ac_test_CFLAGS" != "xy"; then
     
     clang)
         CFLAGS="-O3 -fomit-frame-pointer"
-        AX_CHECK_COMPILER_FLAGS(-mtune=native, CFLAGS="$CFLAGS -mtune=native")
-        AX_CHECK_COMPILER_FLAGS(-fstrict-aliasing,CFLAGS="$CFLAGS -fstrict-aliasing")
+        AX_CHECK_COMPILE_FLAG(-mtune=native, CFLAGS="$CFLAGS -mtune=native")
+        AX_CHECK_COMPILE_FLAG(-fstrict-aliasing,CFLAGS="$CFLAGS -fstrict-aliasing")
         ;;
 
     gnu) 
@@ -73,13 +73,13 @@ if test "x$ac_test_CFLAGS" != "xset" -a "x$ac_test_CFLAGS" != "xy"; then
      CFLAGS="-O3 -fomit-frame-pointer"
 
      # tune for the host by default
-     AX_CHECK_COMPILER_FLAGS(-mtune=native, CFLAGS="$CFLAGS -mtune=native")
+     AX_CHECK_COMPILE_FLAG(-mtune=native, CFLAGS="$CFLAGS -mtune=native")
 
      # -malign-double for x86 systems
-     AX_CHECK_COMPILER_FLAGS(-malign-double, CFLAGS="$CFLAGS -malign-double")
+     AX_CHECK_COMPILE_FLAG(-malign-double, CFLAGS="$CFLAGS -malign-double")
 
      #  -fstrict-aliasing for gcc-2.95+
-     AX_CHECK_COMPILER_FLAGS(-fstrict-aliasing,
+     AX_CHECK_COMPILE_FLAG(-fstrict-aliasing,
 	CFLAGS="$CFLAGS -fstrict-aliasing")
 
      # -fno-schedule-insns is pretty much required on all risc
@@ -90,14 +90,14 @@ if test "x$ac_test_CFLAGS" != "xset" -a "x$ac_test_CFLAGS" != "xy"; then
      # scheduling.  The first pass reorders instructions in a way that
      # is pretty much the worst possible for the purposes of register
      # allocation.  We disable the first pass.
-     AX_CHECK_COMPILER_FLAGS(-fno-schedule-insns, CFLAGS="$CFLAGS -fno-schedule-insns")
+     AX_CHECK_COMPILE_FLAG(-fno-schedule-insns, CFLAGS="$CFLAGS -fno-schedule-insns")
 
      # flags to enable power ISA 2.07 instructions with gcc (always true with vsx)
      if test "$have_vsx" = "yes"; then
-         AX_CHECK_COMPILER_FLAGS(-mcpu=power8, CFLAGS="$CFLAGS -mcpu=power8")
-         AX_CHECK_COMPILER_FLAGS(-mpower8-fusion, CFLAGS="$CFLAGS -mpower8-fusion")
-         AX_CHECK_COMPILER_FLAGS(-mpower8-vector, CFLAGS="$CFLAGS -mpower8-vector")
-         AX_CHECK_COMPILER_FLAGS(-mdirect-move, CFLAGS="$CFLAGS -mdirect-move")
+         AX_CHECK_COMPILE_FLAG(-mcpu=power8, CFLAGS="$CFLAGS -mcpu=power8")
+         AX_CHECK_COMPILE_FLAG(-mpower8-fusion, CFLAGS="$CFLAGS -mpower8-fusion")
+         AX_CHECK_COMPILE_FLAG(-mpower8-vector, CFLAGS="$CFLAGS -mpower8-vector")
+         AX_CHECK_COMPILE_FLAG(-mdirect-move, CFLAGS="$CFLAGS -mdirect-move")
      fi
      ;;
   esac
@@ -113,7 +113,7 @@ if test "x$ac_test_CFLAGS" != "xset" -a "x$ac_test_CFLAGS" != "xy"; then
         CFLAGS="-O3"
   fi
 
-  AX_CHECK_COMPILER_FLAGS($CFLAGS, [], [
+  AX_CHECK_COMPILE_FLAG($CFLAGS, [], [
 	echo ""
         echo "********************************************************"
         echo "* WARNING: The guessed CFLAGS don't seem to work with  *"
diff --git a/m4/ax_check_compile_flag.m4 b/m4/ax_check_compile_flag.m4
new file mode 100644
index 000000000..bd753b34d
--- /dev/null
+++ b/m4/ax_check_compile_flag.m4
@@ -0,0 +1,53 @@
+# ===========================================================================
+#  https://www.gnu.org/software/autoconf-archive/ax_check_compile_flag.html
+# ===========================================================================
+#
+# SYNOPSIS
+#
+#   AX_CHECK_COMPILE_FLAG(FLAG, [ACTION-SUCCESS], [ACTION-FAILURE], [EXTRA-FLAGS], [INPUT])
+#
+# DESCRIPTION
+#
+#   Check whether the given FLAG works with the current language's compiler
+#   or gives an error.  (Warnings, however, are ignored)
+#
+#   ACTION-SUCCESS/ACTION-FAILURE are shell commands to execute on
+#   success/failure.
+#
+#   If EXTRA-FLAGS is defined, it is added to the current language's default
+#   flags (e.g. CFLAGS) when the check is done.  The check is thus made with
+#   the flags: "CFLAGS EXTRA-FLAGS FLAG".  This can for example be used to
+#   force the compiler to issue an error when a bad flag is given.
+#
+#   INPUT gives an alternative input source to AC_COMPILE_IFELSE.
+#
+#   NOTE: Implementation based on AX_CFLAGS_GCC_OPTION. Please keep this
+#   macro in sync with AX_CHECK_{PREPROC,LINK}_FLAG.
+#
+# LICENSE
+#
+#   Copyright (c) 2008 Guido U. Draheim <guidod@gmx.de>
+#   Copyright (c) 2011 Maarten Bosmans <mkbosmans@gmail.com>
+#
+#   Copying and distribution of this file, with or without modification, are
+#   permitted in any medium without royalty provided the copyright notice
+#   and this notice are preserved.  This file is offered as-is, without any
+#   warranty.
+
+#serial 6
+
+AC_DEFUN([AX_CHECK_COMPILE_FLAG],
+[AC_PREREQ(2.64)dnl for _AC_LANG_PREFIX and AS_VAR_IF
+AS_VAR_PUSHDEF([CACHEVAR],[ax_cv_check_[]_AC_LANG_ABBREV[]flags_$4_$1])dnl
+AC_CACHE_CHECK([whether _AC_LANG compiler accepts $1], CACHEVAR, [
+  ax_check_save_flags=$[]_AC_LANG_PREFIX[]FLAGS
+  _AC_LANG_PREFIX[]FLAGS="$[]_AC_LANG_PREFIX[]FLAGS $4 $1"
+  AC_COMPILE_IFELSE([m4_default([$5],[AC_LANG_PROGRAM()])],
+    [AS_VAR_SET(CACHEVAR,[yes])],
+    [AS_VAR_SET(CACHEVAR,[no])])
+  _AC_LANG_PREFIX[]FLAGS=$ax_check_save_flags])
+AS_VAR_IF(CACHEVAR,yes,
+  [m4_default([$2], :)],
+  [m4_default([$3], :)])
+AS_VAR_POPDEF([CACHEVAR])dnl
+])dnl AX_CHECK_COMPILE_FLAGS
diff --git a/m4/ax_check_compiler_flags.m4 b/m4/ax_check_compiler_flags.m4
deleted file mode 100644
index 86eaf15ef..000000000
--- a/m4/ax_check_compiler_flags.m4
+++ /dev/null
@@ -1,40 +0,0 @@
-dnl @synopsis AX_CHECK_COMPILER_FLAGS(FLAGS, [ACTION-SUCCESS], [ACTION-FAILURE])
-dnl @summary check whether FLAGS are accepted by the compiler
-dnl @category Misc
-dnl
-dnl Check whether the given compiler FLAGS work with the current language's
-dnl compiler, or whether they give an error.  (Warnings, however, are
-dnl ignored.)
-dnl
-dnl ACTION-SUCCESS/ACTION-FAILURE are shell commands to execute on
-dnl success/failure.
-dnl
-dnl @version 2005-05-30
-dnl @license GPLWithACException
-dnl @author Steven G. Johnson <stevenj@alum.mit.edu> and Matteo Frigo.
-AC_DEFUN([AX_CHECK_COMPILER_FLAGS],
-[AC_PREREQ(2.59) dnl for _AC_LANG_PREFIX
-AC_MSG_CHECKING([whether _AC_LANG compiler accepts $1])
-dnl Some hackery here since AC_CACHE_VAL can't handle a non-literal varname:
-AS_LITERAL_IF([$1],
-  [AC_CACHE_VAL(AS_TR_SH(ax_cv_[]_AC_LANG_ABBREV[]_flags_$1), [
-      ax_save_FLAGS=$[]_AC_LANG_PREFIX[]FLAGS
-      _AC_LANG_PREFIX[]FLAGS="$1"
-      AC_COMPILE_IFELSE([AC_LANG_PROGRAM()], 
-        AS_TR_SH(ax_cv_[]_AC_LANG_ABBREV[]_flags_$1)=yes,
-        AS_TR_SH(ax_cv_[]_AC_LANG_ABBREV[]_flags_$1)=no)
-      _AC_LANG_PREFIX[]FLAGS=$ax_save_FLAGS])],
-  [ax_save_FLAGS=$[]_AC_LANG_PREFIX[]FLAGS
-   _AC_LANG_PREFIX[]FLAGS="$1"
-   AC_COMPILE_IFELSE([AC_LANG_PROGRAM()], 
-     eval AS_TR_SH(ax_cv_[]_AC_LANG_ABBREV[]_flags_$1)=yes,
-     eval AS_TR_SH(ax_cv_[]_AC_LANG_ABBREV[]_flags_$1)=no)
-   _AC_LANG_PREFIX[]FLAGS=$ax_save_FLAGS])
-eval ax_check_compiler_flags=$AS_TR_SH(ax_cv_[]_AC_LANG_ABBREV[]_flags_$1)
-AC_MSG_RESULT($ax_check_compiler_flags)
-if test "x$ax_check_compiler_flags" = xyes; then
-	m4_default([$2], :)
-else
-	m4_default([$3], :)
-fi
-])dnl AX_CHECK_COMPILER_FLAGS
diff --git a/m4/ax_check_link_flag.m4 b/m4/ax_check_link_flag.m4
new file mode 100644
index 000000000..03a30ce4c
--- /dev/null
+++ b/m4/ax_check_link_flag.m4
@@ -0,0 +1,53 @@
+# ===========================================================================
+#    https://www.gnu.org/software/autoconf-archive/ax_check_link_flag.html
+# ===========================================================================
+#
+# SYNOPSIS
+#
+#   AX_CHECK_LINK_FLAG(FLAG, [ACTION-SUCCESS], [ACTION-FAILURE], [EXTRA-FLAGS], [INPUT])
+#
+# DESCRIPTION
+#
+#   Check whether the given FLAG works with the linker or gives an error.
+#   (Warnings, however, are ignored)
+#
+#   ACTION-SUCCESS/ACTION-FAILURE are shell commands to execute on
+#   success/failure.
+#
+#   If EXTRA-FLAGS is defined, it is added to the linker's default flags
+#   when the check is done.  The check is thus made with the flags: "LDFLAGS
+#   EXTRA-FLAGS FLAG".  This can for example be used to force the linker to
+#   issue an error when a bad flag is given.
+#
+#   INPUT gives an alternative input source to AC_LINK_IFELSE.
+#
+#   NOTE: Implementation based on AX_CFLAGS_GCC_OPTION. Please keep this
+#   macro in sync with AX_CHECK_{PREPROC,COMPILE}_FLAG.
+#
+# LICENSE
+#
+#   Copyright (c) 2008 Guido U. Draheim <guidod@gmx.de>
+#   Copyright (c) 2011 Maarten Bosmans <mkbosmans@gmail.com>
+#
+#   Copying and distribution of this file, with or without modification, are
+#   permitted in any medium without royalty provided the copyright notice
+#   and this notice are preserved.  This file is offered as-is, without any
+#   warranty.
+
+#serial 6
+
+AC_DEFUN([AX_CHECK_LINK_FLAG],
+[AC_PREREQ(2.64)dnl for _AC_LANG_PREFIX and AS_VAR_IF
+AS_VAR_PUSHDEF([CACHEVAR],[ax_cv_check_ldflags_$4_$1])dnl
+AC_CACHE_CHECK([whether the linker accepts $1], CACHEVAR, [
+  ax_check_save_flags=$LDFLAGS
+  LDFLAGS="$LDFLAGS $4 $1"
+  AC_LINK_IFELSE([m4_default([$5],[AC_LANG_PROGRAM()])],
+    [AS_VAR_SET(CACHEVAR,[yes])],
+    [AS_VAR_SET(CACHEVAR,[no])])
+  LDFLAGS=$ax_check_save_flags])
+AS_VAR_IF(CACHEVAR,yes,
+  [m4_default([$2], :)],
+  [m4_default([$3], :)])
+AS_VAR_POPDEF([CACHEVAR])dnl
+])dnl AX_CHECK_LINK_FLAGS
diff --git a/m4/ax_gcc_aligns_stack.m4 b/m4/ax_gcc_aligns_stack.m4
index 5188f6df6..d1562372c 100644
--- a/m4/ax_gcc_aligns_stack.m4
+++ b/m4/ax_gcc_aligns_stack.m4
@@ -11,9 +11,9 @@ dnl
 dnl ACTION-IF-YES/ACTION-IF-NO are shell commands to execute if we are
 dnl using gcc and the stack is/isn't aligned, respectively.
 dnl
-dnl Requires macro: AX_CHECK_COMPILER_FLAGS, AX_GCC_VERSION
+dnl Requires macro: AX_CHECK_COMPILE_FLAG, AX_GCC_VERSION
 dnl
-dnl @version 2005-05-30
+dnl @version 2023-05-14
 dnl @license GPLWithACException
 dnl @author Steven G. Johnson <stevenj@alum.mit.edu>
 AC_DEFUN([AX_GCC_ALIGNS_STACK],
@@ -21,11 +21,11 @@ AC_DEFUN([AX_GCC_ALIGNS_STACK],
 AC_REQUIRE([AC_PROG_CC])
 ax_gcc_aligns_stack=no
 if test "$GCC" = "yes"; then
-AX_CHECK_COMPILER_FLAGS(-mpreferred-stack-boundary=4, [
+AX_CHECK_COMPILE_FLAG(-mpreferred-stack-boundary=4, [
 	AC_MSG_CHECKING([whether the stack is at least 8-byte aligned by gcc])
 	save_CFLAGS="$CFLAGS"
 	CFLAGS="-O"
-	AX_CHECK_COMPILER_FLAGS(-malign-double, CFLAGS="$CFLAGS -malign-double")
+	AX_CHECK_COMPILE_FLAG(-malign-double, CFLAGS="$CFLAGS -malign-double")
 	AC_TRY_RUN([#include <stdlib.h>
 #       include <stdio.h>
 	struct yuck { int blechh; };
--- a/configure.ac
+++ b/configure.ac
@@ -9,7 +9,7 @@
 define(FFTW_MINOR_VERSION, 10)dnl
 
 dnl Version number of the FFTW source package.
-AC_INIT(fftw, FFTW_MAJOR_VERSION.FFTW_MINOR_VERSION, fftw@fftw.org)
+AC_INIT([fftw],[FFTW_MAJOR_VERSION.FFTW_MINOR_VERSION],[fftw@fftw.org])
 AC_CONFIG_SRCDIR(kernel/ifftw.h)
 
 dnl Version number for libtool shared libraries.  Libtool wants a string
@@ -45,27 +45,27 @@
   *) arch_prefers_fma=no;;
 esac
 
-AC_ARG_ENABLE(debug, [AC_HELP_STRING([--enable-debug],[compile fftw with extra runtime checks for debugging])], ok=$enableval, ok=no)
+AC_ARG_ENABLE(debug, [AS_HELP_STRING([--enable-debug],[compile fftw with extra runtime checks for debugging])], ok=$enableval, ok=no)
 if test "$ok" = "yes"; then
     AC_DEFINE(FFTW_DEBUG,1,[Define to enable extra FFTW debugging code.])
 fi
 
-AC_ARG_ENABLE(doc, [AC_HELP_STRING([--disable-doc],[disable building the documentation])], build_doc=$enableval, build_doc=yes)
+AC_ARG_ENABLE(doc, [AS_HELP_STRING([--disable-doc],[disable building the documentation])], build_doc=$enableval, build_doc=yes)
 AM_CONDITIONAL(BUILD_DOC, test x"$build_doc" = xyes)
 
-AC_ARG_ENABLE(random-estimator, [AC_HELP_STRING([--enable-random-estimator],[enable pseudorandom estimator (debugging hack)])], ok=$enableval, ok=no)
+AC_ARG_ENABLE(random-estimator, [AS_HELP_STRING([--enable-random-estimator],[enable pseudorandom estimator (debugging hack)])], ok=$enableval, ok=no)
 if test "$ok" = "yes"; then
     AC_DEFINE(FFTW_RANDOM_ESTIMATOR,1,[Define to enable pseudorandom estimate planning for debugging.])
     CHECK_PL_OPTS="--estimate"
 fi
 
-AC_ARG_ENABLE(alloca, [AC_HELP_STRING([--disable-alloca],[disable use of the alloca() function (may be broken on mingw64)])], ok=$enableval, ok=yes)
+AC_ARG_ENABLE(alloca, [AS_HELP_STRING([--disable-alloca],[disable use of the alloca() function (may be broken on mingw64)])], ok=$enableval, ok=yes)
 if test "$ok" = "yes"; then
     AC_DEFINE(FFTW_ENABLE_ALLOCA,1,[Define to enable the use of alloca().])
 fi
 
-AC_ARG_ENABLE(single, [AC_HELP_STRING([--enable-single],[compile fftw in single precision])], ok=$enableval, ok=no)
-AC_ARG_ENABLE(float, [AC_HELP_STRING([--enable-float],[synonym for --enable-single])], ok=$enableval)
+AC_ARG_ENABLE(single, [AS_HELP_STRING([--enable-single],[compile fftw in single precision])], ok=$enableval, ok=no)
+AC_ARG_ENABLE(float, [AS_HELP_STRING([--enable-float],[synonym for --enable-single])], ok=$enableval)
 if test "$ok" = "yes"; then
     AC_DEFINE(FFTW_SINGLE,1,[Define to compile in single precision.])
     AC_DEFINE(BENCHFFT_SINGLE,1,[Define to compile in single precision.])
@@ -75,7 +75,7 @@
 fi
 AM_CONDITIONAL(SINGLE, test "$ok" = "yes")
 
-AC_ARG_ENABLE(long-double, [AC_HELP_STRING([--enable-long-double],[compile fftw in long-double precision])], ok=$enableval, ok=no)
+AC_ARG_ENABLE(long-double, [AS_HELP_STRING([--enable-long-double],[compile fftw in long-double precision])], ok=$enableval, ok=no)
 if test "$ok" = "yes"; then
     if test "$PRECISION" = "s"; then
         AC_MSG_ERROR([--enable-single/--enable-long-double conflict])
@@ -86,7 +86,7 @@
 fi
 AM_CONDITIONAL(LDOUBLE, test "$ok" = "yes")
 
-AC_ARG_ENABLE(quad-precision, [AC_HELP_STRING([--enable-quad-precision],[compile fftw in quadruple precision if available])], ok=$enableval, ok=no)
+AC_ARG_ENABLE(quad-precision, [AS_HELP_STRING([--enable-quad-precision],[compile fftw in quadruple precision if available])], ok=$enableval, ok=no)
 if test "$ok" = "yes"; then
     if test "$PRECISION" != "d"; then
         AC_MSG_ERROR([conflicting precisions specified])
@@ -108,14 +108,14 @@
 dnl This behavior is pointless in 2016.  --enable-sse2 now works in both precisions,
 dnl and is interpreted as --enable-sse in single precision.  The old flag --enable--se
 dnl is still supported in single-precision only.
-AC_ARG_ENABLE(sse, [AC_HELP_STRING([--enable-sse],[enable SSE optimizations])], have_sse=$enableval, have_sse=no)
+AC_ARG_ENABLE(sse, [AS_HELP_STRING([--enable-sse],[enable SSE optimizations])], have_sse=$enableval, have_sse=no)
 if test "$have_sse" = "yes"; then
     if test "$PRECISION" != "s"; then
             AC_MSG_ERROR([SSE requires single precision])
     fi
 fi
 
-AC_ARG_ENABLE(sse2, [AC_HELP_STRING([--enable-sse2],[enable SSE/SSE2 optimizations])], have_sse2=$enableval, have_sse2=no)
+AC_ARG_ENABLE(sse2, [AS_HELP_STRING([--enable-sse2],[enable SSE/SSE2 optimizations])], have_sse2=$enableval, have_sse2=no)
 if test "$have_sse" = "yes"; then have_sse2=yes; fi
 if test "$have_sse2" = "yes"; then
     AC_DEFINE(HAVE_SSE2,1,[Define to enable SSE/SSE2 optimizations.])
@@ -125,7 +125,7 @@
 fi
 AM_CONDITIONAL(HAVE_SSE2, test "$have_sse2" = "yes")
 
-AC_ARG_ENABLE(avx, [AC_HELP_STRING([--enable-avx],[enable AVX optimizations])], have_avx=$enableval, have_avx=no)
+AC_ARG_ENABLE(avx, [AS_HELP_STRING([--enable-avx],[enable AVX optimizations])], have_avx=$enableval, have_avx=no)
 if test "$have_avx" = "yes"; then
     AC_DEFINE(HAVE_AVX,1,[Define to enable AVX optimizations.])
     if test "$PRECISION" != "d" -a "$PRECISION" != "s"; then
@@ -134,7 +134,7 @@
 fi
 AM_CONDITIONAL(HAVE_AVX, test "$have_avx" = "yes")
 
-AC_ARG_ENABLE(avx2, [AC_HELP_STRING([--enable-avx2],[enable AVX2 optimizations])], have_avx2=$enableval, have_avx2=no)
+AC_ARG_ENABLE(avx2, [AS_HELP_STRING([--enable-avx2],[enable AVX2 optimizations])], have_avx2=$enableval, have_avx2=no)
 if test "$have_avx2" = "yes"; then
     AC_DEFINE(HAVE_AVX2,1,[Define to enable AVX2 optimizations.])
     if test "$PRECISION" != "d" -a "$PRECISION" != "s"; then
@@ -143,7 +143,7 @@
 fi
 AM_CONDITIONAL(HAVE_AVX2, test "$have_avx2" = "yes")
 
-AC_ARG_ENABLE(avx512, [AC_HELP_STRING([--enable-avx512],[enable AVX512 optimizations])], have_avx512=$enableval, have_avx512=no)
+AC_ARG_ENABLE(avx512, [AS_HELP_STRING([--enable-avx512],[enable AVX512 optimizations])], have_avx512=$enableval, have_avx512=no)
 if test "$have_avx512" = "yes"; then
     AC_DEFINE(HAVE_AVX512,1,[Define to enable AVX512 optimizations.])
     if test "$PRECISION" != "d" -a "$PRECISION" != "s"; then
@@ -156,7 +156,7 @@
 dnl since SSE2 is just as fast. However, on AMD processors we can both use
 dnl FMA4, and 128-bit SIMD is better than 256-bit since core pairs in a
 dnl compute unit can execute two 128-bit instructions independently.
-AC_ARG_ENABLE(avx-128-fma, [AC_HELP_STRING([--enable-avx-128-fma],[enable AVX128/FMA optimizations])], have_avx_128_fma=$enableval, have_avx_128_fma=no)
+AC_ARG_ENABLE(avx-128-fma, [AS_HELP_STRING([--enable-avx-128-fma],[enable AVX128/FMA optimizations])], have_avx_128_fma=$enableval, have_avx_128_fma=no)
 if test "$have_avx_128_fma" = "yes"; then
     AC_DEFINE(HAVE_AVX_128_FMA,1,[Define to enable 128-bit FMA AVX optimization])
     AVX_128_FMA_CFLAGS="${AVX_CFLAGS} -mfma4"
@@ -164,7 +164,7 @@
 fi
 AM_CONDITIONAL(HAVE_AVX_128_FMA, test "$have_avx_128_fma" = "yes")
 
-AC_ARG_ENABLE(kcvi, [AC_HELP_STRING([--enable-kcvi],[enable Knights Corner vector instructions optimizations])], have_kcvi=$enableval, have_kcvi=no)
+AC_ARG_ENABLE(kcvi, [AS_HELP_STRING([--enable-kcvi],[enable Knights Corner vector instructions optimizations])], have_kcvi=$enableval, have_kcvi=no)
 if test "$have_kcvi" = "yes"; then
     AC_DEFINE(HAVE_KCVI,1,[Define to enable KCVI optimizations.])
     if test "$PRECISION" != "d" -a "$PRECISION" != "s"; then
@@ -173,7 +173,7 @@
 fi
 AM_CONDITIONAL(HAVE_KCVI, test "$have_kcvi" = "yes")
 
-AC_ARG_ENABLE(altivec, [AC_HELP_STRING([--enable-altivec],[enable Altivec optimizations])], have_altivec=$enableval, have_altivec=no)
+AC_ARG_ENABLE(altivec, [AS_HELP_STRING([--enable-altivec],[enable Altivec optimizations])], have_altivec=$enableval, have_altivec=no)
 if test "$have_altivec" = "yes"; then
     AC_DEFINE(HAVE_ALTIVEC,1,[Define to enable Altivec optimizations.])
     if test "$PRECISION" != "s"; then
@@ -182,13 +182,13 @@
 fi
 AM_CONDITIONAL(HAVE_ALTIVEC, test "$have_altivec" = "yes")
 
-AC_ARG_ENABLE(vsx, [AC_HELP_STRING([--enable-vsx],[enable IBM VSX optimizations])], have_vsx=$enableval, have_vsx=no)
+AC_ARG_ENABLE(vsx, [AS_HELP_STRING([--enable-vsx],[enable IBM VSX optimizations])], have_vsx=$enableval, have_vsx=no)
 if test "$have_vsx" = "yes"; then
         AC_DEFINE(HAVE_VSX,1,[Define to enable IBM VSX optimizations.])
 fi
 AM_CONDITIONAL(HAVE_VSX, test "$have_vsx" = "yes")
 
-AC_ARG_ENABLE(neon, [AC_HELP_STRING([--enable-neon],[enable ARM NEON optimizations])], have_neon=$enableval, have_neon=no)
+AC_ARG_ENABLE(neon, [AS_HELP_STRING([--enable-neon],[enable ARM NEON optimizations])], have_neon=$enableval, have_neon=no)
 if test "$have_neon" = "yes"; then
     AC_DEFINE(HAVE_NEON,1,[Define to enable ARM NEON optimizations.])
         case "${host_cpu}" in
@@ -203,33 +203,33 @@
 fi
 AM_CONDITIONAL(HAVE_NEON, test "$have_neon" = "yes")
 
-AC_ARG_ENABLE(armv8-pmccntr-el0, [AC_HELP_STRING([--enable-armv8-pmccntr-el0],[enable the cycle counter on ARMv8 via the PMCCNTR_EL0 register (see README-perfcounters for details and mandatory instructions)])], have_armv8pmccntrel0=$enableval)
+AC_ARG_ENABLE(armv8-pmccntr-el0, [AS_HELP_STRING([--enable-armv8-pmccntr-el0],[enable the cycle counter on ARMv8 via the PMCCNTR_EL0 register (see README-perfcounters for details and mandatory instructions)])], have_armv8pmccntrel0=$enableval)
 if test "$have_armv8pmccntrel0"x = "yes"x; then
     AC_DEFINE(HAVE_ARMV8_PMCCNTR_EL0,1,[Define if you have enabled the PMCCNTR_EL0 cycle counter on ARMv8])
 fi
 
-AC_ARG_ENABLE(armv8-cntvct-el0, [AC_HELP_STRING([--enable-armv8-cntvct-el0],[enable the cycle counter on ARMv8 via the CNTVCT_EL0 register (see README-perfcounters for details and mandatory instructions)])], have_armv8cntvctel0=$enableval)
+AC_ARG_ENABLE(armv8-cntvct-el0, [AS_HELP_STRING([--enable-armv8-cntvct-el0],[enable the cycle counter on ARMv8 via the CNTVCT_EL0 register (see README-perfcounters for details and mandatory instructions)])], have_armv8cntvctel0=$enableval)
 if test "$have_armv8cntvctel0"x = "yes"x; then
     AC_DEFINE(HAVE_ARMV8_CNTVCT_EL0,1,[Define if you have enabled the CNTVCT_EL0 cycle counter on ARMv8])
 fi
 
-AC_ARG_ENABLE(armv7a-cntvct, [AC_HELP_STRING([--enable-armv7a-cntvct],[enable the cycle counter on Armv7a via the CNTVCT register (see README-perfcounters for details and mandatory instructions)])], have_armv7acntvct=$enableval)
+AC_ARG_ENABLE(armv7a-cntvct, [AS_HELP_STRING([--enable-armv7a-cntvct],[enable the cycle counter on Armv7a via the CNTVCT register (see README-perfcounters for details and mandatory instructions)])], have_armv7acntvct=$enableval)
 if test "$have_armv7acntvct"x = "yes"x; then
     AC_DEFINE(HAVE_ARMV7A_CNTVCT,1,[Define if you have enabled the CNTVCT cycle counter on ARMv7a])
 fi
 
-AC_ARG_ENABLE(armv7a-pmccntr, [AC_HELP_STRING([--enable-armv7a-pmccntr],[enable the cycle counter on Armv7a via the PMCCNTR register (see README-perfcounters for details and mandatory instructions)])], have_armv7apmccntr=$enableval)
+AC_ARG_ENABLE(armv7a-pmccntr, [AS_HELP_STRING([--enable-armv7a-pmccntr],[enable the cycle counter on Armv7a via the PMCCNTR register (see README-perfcounters for details and mandatory instructions)])], have_armv7apmccntr=$enableval)
 if test "$have_armv7apmccntr"x = "yes"x; then
     AC_DEFINE(HAVE_ARMV7A_PMCCNTR,1,[Define if you have enabled the PMCCNTR cycle counter on ARMv7a])
 fi
 
-AC_ARG_ENABLE(generic-simd128, [AC_HELP_STRING([--enable-generic-simd128],[enable generic (gcc) 128-bit SIMD optimizations])], have_generic_simd128=$enableval, have_generic_simd128=no)
+AC_ARG_ENABLE(generic-simd128, [AS_HELP_STRING([--enable-generic-simd128],[enable generic (gcc) 128-bit SIMD optimizations])], have_generic_simd128=$enableval, have_generic_simd128=no)
 if test "$have_generic_simd128" = "yes"; then
         AC_DEFINE(HAVE_GENERIC_SIMD128,1,[Define to enable generic (gcc) 128-bit SIMD optimizations.])
 fi
 AM_CONDITIONAL(HAVE_GENERIC_SIMD128, test "$have_generic_simd128" = "yes")
 
-AC_ARG_ENABLE(generic-simd256, [AC_HELP_STRING([--enable-generic-simd256],[enable generic (gcc) 256-bit SIMD optimizations])], have_generic_simd256=$enableval, have_generic_simd256=no)
+AC_ARG_ENABLE(generic-simd256, [AS_HELP_STRING([--enable-generic-simd256],[enable generic (gcc) 256-bit SIMD optimizations])], have_generic_simd256=$enableval, have_generic_simd256=no)
 if test "$have_generic_simd256" = "yes"; then
         AC_DEFINE(HAVE_GENERIC_SIMD256,1,[Define to enable generic (gcc) 256-bit SIMD optimizations.])
 fi
@@ -237,7 +237,7 @@
 
 
 dnl FIXME:
-dnl AC_ARG_ENABLE(mips-ps, [AC_HELP_STRING([--enable-mips-ps],[enable MIPS pair-single optimizations])], have_mips_ps=$enableval, have_mips_ps=no)
+dnl AC_ARG_ENABLE(mips-ps, [AS_HELP_STRING([--enable-mips-ps],[enable MIPS pair-single optimizations])], have_mips_ps=$enableval, have_mips_ps=no)
 dnl if test "$have_mips_ps" = "yes"; then
 dnl 	AC_DEFINE(HAVE_MIPS_PS,1,[Define to enable MIPS paired-single optimizations.])
 dnl 	if test "$PRECISION" != "s"; then
@@ -246,31 +246,31 @@
 dnl fi
 dnl AM_CONDITIONAL(HAVE_MIPS_PS, test "$have_mips_ps" = "yes")
 
-AC_ARG_WITH(slow-timer, [AC_HELP_STRING([--with-slow-timer],[use low-precision timers (SLOW)])], with_slow_timer=$withval, with_slow_timer=no)
+AC_ARG_WITH(slow-timer, [AS_HELP_STRING([--with-slow-timer],[use low-precision timers (SLOW)])], with_slow_timer=$withval, with_slow_timer=no)
 if test "$with_slow_timer" = "yes"; then
     AC_DEFINE(WITH_SLOW_TIMER,1,[Use low-precision timers, making planner very slow])
 fi
 
-AC_ARG_ENABLE(mips_zbus_timer, [AC_HELP_STRING([--enable-mips-zbus-timer],[use MIPS ZBus cycle-counter])], have_mips_zbus_timer=$enableval, have_mips_zbus_timer=no)
+AC_ARG_ENABLE(mips_zbus_timer, [AS_HELP_STRING([--enable-mips-zbus-timer],[use MIPS ZBus cycle-counter])], have_mips_zbus_timer=$enableval, have_mips_zbus_timer=no)
 if test "$have_mips_zbus_timer" = "yes"; then
     AC_DEFINE(HAVE_MIPS_ZBUS_TIMER,1,[Define to enable use of MIPS ZBus cycle-counter.])
 fi
 
-AC_ARG_WITH(our-malloc, [AC_HELP_STRING([--with-our-malloc],[use our aligned malloc (helpful for Win32)])], with_our_malloc=$withval, with_our_malloc=no)
-AC_ARG_WITH(our-malloc16, [AC_HELP_STRING([--with-our-malloc16],[Obsolete alias for --with-our-malloc16])], with_our_malloc=$withval)
+AC_ARG_WITH(our-malloc, [AS_HELP_STRING([--with-our-malloc],[use our aligned malloc (helpful for Win32)])], with_our_malloc=$withval, with_our_malloc=no)
+AC_ARG_WITH(our-malloc16, [AS_HELP_STRING([--with-our-malloc16],[Obsolete alias for --with-our-malloc16])], with_our_malloc=$withval)
 if test "$with_our_malloc" = "yes"; then
     AC_DEFINE(WITH_OUR_MALLOC,1,[Use our own aligned malloc routine; mainly helpful for Windows systems lacking aligned allocation system-library routines.])
 fi
 
-AC_ARG_WITH(windows-f77-mangling, [AC_HELP_STRING([--with-windows-f77-mangling],[use common Win32 Fortran interface styles])], with_windows_f77_mangling=$withval, with_windows_f77_mangling=no)
+AC_ARG_WITH(windows-f77-mangling, [AS_HELP_STRING([--with-windows-f77-mangling],[use common Win32 Fortran interface styles])], with_windows_f77_mangling=$withval, with_windows_f77_mangling=no)
 if test "$with_windows_f77_mangling" = "yes"; then
     AC_DEFINE(WINDOWS_F77_MANGLING,1,[Use common Windows Fortran mangling styles for the Fortran interfaces.])
 fi
 
-AC_ARG_WITH(incoming-stack-boundary, [AC_HELP_STRING([--with-incoming-stack-boundary=X],[Assume that stack is aligned to (1<<X) bytes])], with_incoming_stack_boundary=$withval, with_incoming_stack_boundary=no)
+AC_ARG_WITH(incoming-stack-boundary, [AS_HELP_STRING([--with-incoming-stack-boundary=X],[Assume that stack is aligned to (1<<X) bytes])], with_incoming_stack_boundary=$withval, with_incoming_stack_boundary=no)
 
 
-AC_ARG_ENABLE(fma, [AC_HELP_STRING([--enable-fma],[enable if the machine architecture "naturally" prefers fused multiply-add instructions])], arch_prefers_fma=$enableval)
+AC_ARG_ENABLE(fma, [AS_HELP_STRING([--enable-fma],[enable if the machine architecture "naturally" prefers fused multiply-add instructions])], arch_prefers_fma=$enableval)
 if test "$arch_prefers_fma"x = "yes"x; then
         AC_DEFINE(ARCH_PREFERS_FMA,1,[Define if the machine architecture "naturally" prefers fused multiply-add instructions])
 fi
@@ -293,7 +293,7 @@
 AC_PROG_LN_S
 AC_PROG_MAKE_SET
 AC_LIBTOOL_WIN32_DLL
-AC_PROG_LIBTOOL
+LT_INIT
 AC_PROG_RANLIB
 
 AC_CHECK_PROG(OCAMLBUILD, ocamlbuild, ocamlbuild)
@@ -333,12 +333,12 @@
 
 case "${ax_cv_c_compiler_vendor}" in
    hp) # must (sometimes) manually increase cpp limits to handle fftw3.h
-        AX_CHECK_COMPILER_FLAGS([-Wp,-H128000],
+        AX_CHECK_COMPILE_FLAG([-Wp,-H128000],
                         [CC="$CC -Wp,-H128000"])
         ;;
 
    portland) # -Masmkeyword required for asm("") cycle counters
-        AX_CHECK_COMPILER_FLAGS([-Masmkeyword],
+        AX_CHECK_COMPILE_FLAG([-Masmkeyword],
                                 [CC="$CC -Masmkeyword"])
         ;;
 esac
@@ -349,50 +349,50 @@
         # SSE/SSE2
         if test "$have_sse2" = "yes" -a "x$SSE2_CFLAGS" = x; then
             if test "$PRECISION" = d; then flag=msse2; else flag=msse; fi
-            AX_CHECK_COMPILER_FLAGS(-$flag, [SSE2_CFLAGS="-$flag"],
+            AX_CHECK_COMPILE_FLAG(-$flag, [SSE2_CFLAGS="-$flag"],
             [AC_MSG_ERROR([Need a version of gcc with -$flag])])
         fi
 
         # AVX
         if test "$have_avx" = "yes" -a "x$AVX_CFLAGS" = x; then
-            AX_CHECK_COMPILER_FLAGS(-mavx, [AVX_CFLAGS="-mavx"],
+            AX_CHECK_COMPILE_FLAG(-mavx, [AVX_CFLAGS="-mavx"],
             [AC_MSG_ERROR([Need a version of gcc with -mavx])])
         fi
 
         # AVX2
         if test "$have_avx2" = "yes" -a "x$AVX2_CFLAGS" = x; then
-            AX_CHECK_COMPILER_FLAGS(-mavx2, [AVX2_CFLAGS="-mavx2"],
+            AX_CHECK_COMPILE_FLAG(-mavx2, [AVX2_CFLAGS="-mavx2"],
                 [AC_MSG_ERROR([Need a version of gcc with -mavx2])])
-            AX_CHECK_COMPILER_FLAGS(-mfma, [AVX2_CFLAGS="$AVX2_CFLAGS -mfma"],
+            AX_CHECK_COMPILE_FLAG(-mfma, [AVX2_CFLAGS="$AVX2_CFLAGS -mfma"],
                 [AC_MSG_WARN([Need a version of gcc with -mfma (harmless for icc)])])
         fi
 
         # AVX512
         if test "$have_avx512" = "yes" -a "x$AVX512_CFLAGS" = x; then
-            AX_CHECK_COMPILER_FLAGS(-mavx512f, [AVX512_CFLAGS="-mavx512f"],
+            AX_CHECK_COMPILE_FLAG(-mavx512f, [AVX512_CFLAGS="-mavx512f"],
             [AC_MSG_ERROR([Need a version of gcc with -mavx512f])])
         fi
 
         if test "$host_vendor" = "apple"; then
             # We need to tell gcc to use an external assembler to get AVX/AVX2 with gcc on OS X
-            AX_CHECK_COMPILER_FLAGS([-Wa,-q], [CFLAGS="$CFLAGS -Wa,-q"])
+            AX_CHECK_COMPILE_FLAG([-Wa,-q], [CFLAGS="$CFLAGS -Wa,-q"])
             # Disable the new compact unwinding format so we avoid warnings/potential errors.
-            AX_CHECK_COMPILER_FLAGS([-Wl,-no_compact_unwind], [CFLAGS="$CFLAGS -Wl,-no_compact_unwind"])
+            AX_CHECK_LINK_FLAG([-Wl,-no_compact_unwind], [CFLAGS="$CFLAGS -Wl,-no_compact_unwind"])
         fi
 
         # KCVI
         if test "$have_kcvi" = "yes" -a "x$KCVI_CFLAGS" = x; then
-            AX_CHECK_COMPILER_FLAGS(-mmic, [KCVI_CFLAGS="-mmic"],
+            AX_CHECK_COMPILE_FLAG(-mmic, [KCVI_CFLAGS="-mmic"],
             [AC_MSG_ERROR([Need a version of icc with -mmic])])
         fi
 
         if test "$have_altivec" = "yes" -a "x$ALTIVEC_CFLAGS" = x; then
             # -DFAKE__VEC__ is a workaround because gcc-3.3 does not
             # #define __VEC__ with -maltivec.
-            AX_CHECK_COMPILER_FLAGS(-faltivec, [ALTIVEC_CFLAGS="-faltivec"],
-            [AX_CHECK_COMPILER_FLAGS(-maltivec -mabi=altivec,
+            AX_CHECK_COMPILE_FLAG(-faltivec, [ALTIVEC_CFLAGS="-faltivec"],
+            [AX_CHECK_COMPILE_FLAG(-maltivec -mabi=altivec,
                 [ALTIVEC_CFLAGS="-maltivec -mabi=altivec -DFAKE__VEC__"],
-                [AX_CHECK_COMPILER_FLAGS(-fvec, [ALTIVEC_CFLAGS="-fvec"],
+                [AX_CHECK_COMPILE_FLAG(-fvec, [ALTIVEC_CFLAGS="-fvec"],
                 [AC_MSG_ERROR([Need a version of gcc with -maltivec])])])])
         fi
 
@@ -401,14 +401,14 @@
                 ;;
             *)
                 if test "$have_neon" = "yes" -a "x$NEON_CFLAGS" = x; then
-                    AX_CHECK_COMPILER_FLAGS(-mfpu=neon, [NEON_CFLAGS="-mfpu=neon"],
+                    AX_CHECK_COMPILE_FLAG(-mfpu=neon, [NEON_CFLAGS="-mfpu=neon"],
                 [AC_MSG_ERROR([Need a version of gcc with -mfpu=neon])])
                 fi
                 ;;
         esac
 
         if test "$have_vsx" = "yes" -a "x$VSX_CFLAGS" = x; then
-            AX_CHECK_COMPILER_FLAGS(-mvsx, [VSX_CFLAGS="-mvsx"],
+            AX_CHECK_COMPILE_FLAG(-mvsx, [VSX_CFLAGS="-mvsx"],
                 [AC_MSG_ERROR([Need a version of gcc with -mvsx])])
         fi
 
@@ -416,10 +416,10 @@
     dnl elif test "$have_mips_ps" = "yes"; then
     dnl     # Just punt here and use only new 4.2 compiler :(
     dnl 	# Should add section for older compilers...
-    dnl 	AX_CHECK_COMPILER_FLAGS(-mpaired-single,
+    dnl 	AX_CHECK_COMPILE_FLAG(-mpaired-single,
     dnl 	    [SIMD_CFLAGS="-mpaired-single"],
     dnl 	    #[AC_MSG_ERROR([Need a version of gcc with -mpaired-single])])
-    dnl 	    [AX_CHECK_COMPILER_FLAGS(-march=mips64,
+    dnl 	    [AX_CHECK_COMPILE_FLAG(-march=mips64,
     dnl 	      [SIMD_CFLAGS="-march=mips64"],
     dnl 	        [AC_MSG_ERROR(
     dnl 		 [Need a version of gcc with -mpaired-single or -march=mips64])
@@ -430,27 +430,27 @@
     clang)
 
         if test "$have_avx" = "yes" -a "x$AVX_CFLAGS" = x; then
-            AX_CHECK_COMPILER_FLAGS(-mavx, [AVX_CFLAGS="-mavx"],
+            AX_CHECK_COMPILE_FLAG(-mavx, [AVX_CFLAGS="-mavx"],
                 [AC_MSG_ERROR([Need a version of clang with -mavx])])
         fi
 
         if test "$have_avx2" = "yes" -a "x$AVX2_CFLAGS" = x; then
-                AX_CHECK_COMPILER_FLAGS(-mavx2, [AVX2_CFLAGS="-mavx2"],
+                AX_CHECK_COMPILE_FLAG(-mavx2, [AVX2_CFLAGS="-mavx2"],
                     [AC_MSG_ERROR([Need a version of clang with -mavx2])])
-                AX_CHECK_COMPILER_FLAGS(-mfma, [AVX2_CFLAGS="$AVX2_CFLAGS -mfma"])
+                AX_CHECK_COMPILE_FLAG(-mfma, [AVX2_CFLAGS="$AVX2_CFLAGS -mfma"])
         fi
 
         # AVX512
         if test "$have_avx512" = "yes" -a "x$AVX512_CFLAGS" = x; then
-            AX_CHECK_COMPILER_FLAGS(-mavx512f, [AVX512_CFLAGS="-mavx512f"],
+            AX_CHECK_COMPILE_FLAG(-mavx512f, [AVX512_CFLAGS="-mavx512f"],
             [AC_MSG_ERROR([Need a version of clang with -mavx512f])])
         fi
 
         if test "$have_vsx" = "yes" -a "x$VSX_CFLAGS" = x; then
             # clang appears to need both -mvsx and -maltivec for VSX
-            AX_CHECK_COMPILER_FLAGS(-maltivec, [VSX_CFLAGS="-maltivec"],
+            AX_CHECK_COMPILE_FLAG(-maltivec, [VSX_CFLAGS="-maltivec"],
                 [AC_MSG_ERROR([Need a version of gcc with -maltivec])])
-            AX_CHECK_COMPILER_FLAGS(-mvsx, [VSX_CFLAGS="-mvsx $VSX_CFLAGS"],
+            AX_CHECK_COMPILE_FLAG(-mvsx, [VSX_CFLAGS="-mvsx $VSX_CFLAGS"],
                 [AC_MSG_ERROR([Need a version of gcc with -mvsx])])
         fi
         ;;
@@ -458,7 +458,7 @@
     ibm)
         if test "$have_vsx" = "yes" -a "x$VSX_CFLAGS" = x; then
             # Note that IBM xlC uses -qaltivec for VSX too.
-            AX_CHECK_COMPILER_FLAGS(-qaltivec, [VSX_CFLAGS="-qaltivec"],
+            AX_CHECK_COMPILE_FLAG(-qaltivec, [VSX_CFLAGS="-qaltivec"],
                 [AC_MSG_ERROR([Need a version of gcc with -qaltivec])])
         fi
         ;;
@@ -478,7 +478,7 @@
    case "${ax_cv_c_compiler_vendor}" in
       gnu)
         tentative_flags="-mincoming-stack-boundary=$with_incoming_stack_boundary";
-        AX_CHECK_COMPILER_FLAGS($tentative_flags,
+        AX_CHECK_COMPILE_FLAG($tentative_flags,
               [STACK_ALIGN_CFLAGS=$tentative_flags])
       ;;
    esac
@@ -576,9 +576,9 @@
 dnl Cray UNICOS _rtc() (real-time clock) intrinsic
 AC_MSG_CHECKING([for _rtc intrinsic])
 rtc_ok=yes
-AC_TRY_LINK([#ifdef HAVE_INTRINSICS_H
+AC_LINK_IFELSE([AC_LANG_PROGRAM([[#ifdef HAVE_INTRINSICS_H
 #include <intrinsics.h>
-#endif], [_rtc()], [AC_DEFINE(HAVE__RTC,1,[Define if you have the UNICOS _rtc() intrinsic.])], [rtc_ok=no])
+#endif]], [[_rtc()]])],[AC_DEFINE(HAVE__RTC,1,[Define if you have the UNICOS _rtc() intrinsic.])],[rtc_ok=no])
 AC_MSG_RESULT($rtc_ok)
 
 if test "$PRECISION" = "l"; then
@@ -586,8 +586,8 @@
 fi
 
 AC_MSG_CHECKING([for isnan])
-AC_TRY_LINK([#include <math.h>
-], if (!isnan(3.14159)) isnan(2.7183);, ok=yes, ok=no)
+AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <math.h>
+]], [[if (!isnan(3.14159)) isnan(2.7183);]])],[ok=yes],[ok=no])
 if test "$ok" = "yes"; then
     AC_DEFINE(HAVE_ISNAN,1,[Define if the isnan() function/macro is available.])
 fi
@@ -604,7 +604,7 @@
 dnl add gcc warnings, in debug/maintainer mode only
 if test "$enable_debug" = yes || test "$USE_MAINTAINER_MODE" = yes; then
 if test "$ac_test_CFLAGS" != "set"; then
-    if test $ac_cv_prog_gcc = yes; then
+    if test $ac_cv_c_compiler_gnu = yes; then
         CFLAGS="$CFLAGS -Wall -W -Wcast-qual -Wpointer-arith -Wcast-align -pedantic -Wno-long-long -Wshadow -Wbad-function-cast -Wwrite-strings -Wstrict-prototypes -Wredundant-decls -Wnested-externs" # -Wundef -Wconversion -Wmissing-prototypes -Wmissing-declarations
     fi
 fi
@@ -631,7 +631,7 @@
 
 dnl -----------------------------------------------------------------------
 
-AC_ARG_ENABLE(fortran, [AC_HELP_STRING([--disable-fortran],[don't include Fortran-callable wrappers])], enable_fortran=$enableval, enable_fortran=yes)
+AC_ARG_ENABLE(fortran, [AS_HELP_STRING([--disable-fortran],[don't include Fortran-callable wrappers])], enable_fortran=$enableval, enable_fortran=yes)
 
 if test "$enable_fortran" = "yes"; then
     AC_PROG_F77
@@ -662,27 +662,27 @@
     with_g77_wrappers=no
 fi
 
-AC_ARG_WITH(g77-wrappers, [AC_HELP_STRING([--with-g77-wrappers],[force inclusion of g77-compatible wrappers in addition to any other Fortran compiler that is detected])], with_g77_wrappers=$withval)
+AC_ARG_WITH(g77-wrappers, [AS_HELP_STRING([--with-g77-wrappers],[force inclusion of g77-compatible wrappers in addition to any other Fortran compiler that is detected])], with_g77_wrappers=$withval)
 if test "x$with_g77_wrappers" = "xyes"; then
     AC_DEFINE(WITH_G77_WRAPPERS,1,[Include g77-compatible wrappers in addition to any other Fortran wrappers.])
 fi
 
 dnl -----------------------------------------------------------------------
 have_smp="no"
-AC_ARG_ENABLE(openmp, [AC_HELP_STRING([--enable-openmp],[use OpenMP directives for parallelism])], enable_openmp=$enableval, enable_openmp=no)
+AC_ARG_ENABLE(openmp, [AS_HELP_STRING([--enable-openmp],[use OpenMP directives for parallelism])], enable_openmp=$enableval, enable_openmp=no)
 
 if test "$enable_openmp" = "yes"; then
    AC_DEFINE(HAVE_OPENMP,1,[Define to enable OpenMP])
    AX_OPENMP([], [AC_MSG_ERROR([don't know how to enable OpenMP])])
 fi
 
-AC_ARG_ENABLE(threads, [AC_HELP_STRING([--enable-threads],[compile FFTW SMP threads library])], enable_threads=$enableval, enable_threads=no)
+AC_ARG_ENABLE(threads, [AS_HELP_STRING([--enable-threads],[compile FFTW SMP threads library])], enable_threads=$enableval, enable_threads=no)
 
 if test "$enable_threads" = "yes"; then
    AC_DEFINE(HAVE_THREADS,1,[Define to enable SMP threads])
 fi
 
-AC_ARG_WITH(combined-threads, [AC_HELP_STRING([--with-combined-threads],[combine threads into main libfftw3])], with_combined_threads=$withval, with_combined_threads=no)
+AC_ARG_WITH(combined-threads, [AS_HELP_STRING([--with-combined-threads],[combine threads into main libfftw3])], with_combined_threads=$withval, with_combined_threads=no)
 
 if test "$with_combined_threads" = yes; then
     if test "$enable_openmp" = "yes"; then
@@ -699,10 +699,7 @@
         # Win32 threads are the default on Windows:
     if test -z "$THREADLIBS"; then
         AC_MSG_CHECKING([for Win32 threads])
-        AC_TRY_LINK([#include <windows.h>],
-            [_beginthreadex(0,0,0,0,0,0);],
-            [THREADLIBS=" "; AC_MSG_RESULT(yes)],
-            [AC_MSG_RESULT(no)])
+        AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <windows.h>]], [[_beginthreadex(0,0,0,0,0,0);]])],[THREADLIBS=" "; AC_MSG_RESULT(yes)],[AC_MSG_RESULT(no)])
     fi
 
     # POSIX threads, the default choice everywhere else:
@@ -728,10 +725,10 @@
 AC_MSG_CHECKING([whether a cycle counter is available])
 save_CPPFLAGS=$CPPFLAGS
 CPPFLAGS="$CPPFLAGS -I$srcdir/kernel"
-AC_TRY_CPP([#include "cycle.h"
+AC_PREPROC_IFELSE([AC_LANG_SOURCE([[#include "cycle.h"
 #ifndef HAVE_TICK_COUNTER
 #  error No cycle counter
-#endif], [ok=yes], [ok=no])
+#endif]])],[ok=yes],[ok=no])
 CPPFLAGS=$save_CPPFLAGS
 AC_MSG_RESULT($ok)
 if test $ok = no && test "x$with_slow_timer" = xno; then
--- a/bootstrap.sh
+++ b/bootstrap.sh
@@ -18,9 +18,3 @@
 autoreconf --verbose --install --symlink --force
 
 rm -f config.cache
-
-# --enable-maintainer-mode enables build of genfft and automatic
-# rebuild of codelets whenever genfft changes
-(
-    ./configure --disable-shared --enable-maintainer-mode --enable-threads $*
-)

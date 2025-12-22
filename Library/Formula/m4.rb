class M4 < Formula
  desc "Macro processing language"
  homepage "https://www.gnu.org/software/m4"
  url "https://ftpmirror.gnu.org/m4/m4-1.4.19.tar.xz"
  mirror "https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz"
  sha256 "63aede5c6d33b6d9b13511cd0be2cac046f2e70fd0a07aa9573a04a82783af96"
  license "GPL-3.0-or-later"

  bottle do
    sha256 "fef063d036e02a3c6af9e3818b2ea25aaa1700b2146a1fa670c58729532b590d" => :tiger_altivec
    sha256 "a158b4e4b222684545f0f3ec082df5c78398863d2bc2c5712f5d4bf840d8e40c" => :tiger_g3
  end

  keg_only :provided_by_osx

  # Backport gnulib fixes for libsigsegv detection
  # https://git.savannah.gnu.org/cgit/gnulib.git/commit/m4?id=4ea0e64a8db7064427f6aa5624a4efd4b41db132
  # Skip the gnulib tests as they have their own set of problems which has nothing to do with what's being built.
  # Fix checks/198.sysval in test suite using version generated from m4's branch-1.4
  # https://git.savannah.gnu.org/cgit/m4.git/commit/doc/m4.texi?h=branch-1.4&id=cd7f4d153ccccf601751e9fa82424412f6ecfc96
  # These patches can be dropped with next version upgrade
  patch :p0, :DATA

  option "with-tests", "Build and run the test suite"

  # sigsegv.c: In function 'sigsegv_handler':
  # sigsegv.c:938: error: 'struct mcontext' has no member named '__ss'
  depends_on "libsigsegv" if MacOS.version == :tiger

  def install
    args = [
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
    ]

    args << "--with-libsigsegv" if MacOS.version == :tiger
    args << "--with-libsigsegv-prefix=#{Formula["libsigsegv"].opt_prefix}" if MacOS.version == :tiger

    # Since we are patching the autotools infra, the build time checks fail, calling to autoreconf
    # Just to keep it happy, so we don't create a circular dependency by requiring autoconf, touch.
    # These touch statements can be removed with the next version upgrade along with patches
    system "touch", "configure.ac"
    system "touch", "aclocal.m4"
    system "touch", "Makefile.in"
    system "touch", "configure"
    system "touch", "lib/config.hin"

    system "./configure", *args
    system "make"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  test do
    assert_match "Homebrew",
      pipe_output("#{bin}/m4", "define(TEST, Homebrew)\nTEST\n")
  end
end
__END__
-- configure	2025-03-29 15:48:39.000000000 +0000
+++ configure	2025-03-29 16:14:00.000000000 +0000
@@ -954,10 +954,6 @@
 GL_GENERATE_SIGSEGV_H_FALSE
 GL_GENERATE_SIGSEGV_H_TRUE
 SIGSEGV_H
-LIBSIGSEGV_PREFIX
-LTLIBSIGSEGV
-LIBSIGSEGV
-HAVE_LIBSIGSEGV
 ASM_SYMBOL_PREFIX
 NEXT_AS_FIRST_DIRECTIVE_SIGNAL_H
 NEXT_SIGNAL_H
@@ -1884,6 +1880,10 @@
 HAVE__EXIT
 LTLIBCSTACK
 LIBCSTACK
+LIBSIGSEGV_PREFIX
+LTLIBSIGSEGV
+LIBSIGSEGV
+HAVE_LIBSIGSEGV
 GL_M4_GNULIB_MDA_WCSDUP
 GL_M4_GNULIB_WCSFTIME
 GL_M4_GNULIB_WCSWIDTH
@@ -2211,6 +2211,9 @@
 AM_DEFAULT_VERBOSITY
 AM_DEFAULT_V
 AM_V
+CSCOPE
+ETAGS
+CTAGS
 am__untar
 am__tar
 AMTAR
@@ -2285,12 +2288,12 @@
 enable_gcc_warnings
 enable_cross_guesses
 enable_assert
+with_libsigsegv
 with_gnu_ld
 enable_rpath
+with_libsigsegv_prefix
 with_libiconv_prefix
 with_included_regex
-with_libsigsegv
-with_libsigsegv_prefix
 with_packager
 with_packager_version
 with_packager_bug_reports
@@ -2960,17 +2963,17 @@
 Optional Packages:
   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
+  --with-libsigsegv       use the GNU libsigsegv library, when present,
+                          instead of the gnulib module 'sigsegv'
   --with-gnu-ld           assume the C compiler uses GNU ld [default=no]
+  --with-libsigsegv-prefix[=DIR]  search for libsigsegv in DIR/include and DIR/lib
+  --without-libsigsegv-prefix     don't search for libsigsegv in includedir and libdir
   --with-libiconv-prefix[=DIR]  search for libiconv in DIR/include and DIR/lib
   --without-libiconv-prefix     don't search for libiconv in includedir and libdir
   --without-included-regex
                           don't compile regex; this is the default on systems
                           with recent-enough versions of the GNU C Library
                           (use with caution on other systems).
-  --with-libsigsegv       use the GNU libsigsegv library, when present,
-                          instead of the gnulib module 'sigsegv'
-  --with-libsigsegv-prefix[=DIR]  search for libsigsegv in DIR/include and DIR/lib
-  --without-libsigsegv-prefix     don't search for libsigsegv in includedir and libdir
   --with-packager         String identifying the packager of this software
   --with-packager-version Packager-specific version information
   --with-packager-bug-reports
@@ -5185,6 +5188,20 @@
 
 
 
+# Variables for tags utilities; see am/tags.am
+if test -z "$CTAGS"; then
+  CTAGS=ctags
+fi
+
+if test -z "$ETAGS"; then
+  ETAGS=etags
+fi
+
+if test -z "$CSCOPE"; then
+  CSCOPE=cscope
+fi
+
+
 
 # POSIX will say in a future version that running "rm -f" with no argument
 # is OK; and we want to be able to make that assumption in our Makefile
@@ -10957,472 +10974,1732 @@
 
 
 
-    HAVE__EXIT=1;
-  HAVE_ALIGNED_ALLOC=1;
-  HAVE_ATOLL=1;
-  HAVE_CANONICALIZE_FILE_NAME=1;
-  HAVE_DECL_ECVT=1;
-  HAVE_DECL_FCVT=1;
-  HAVE_DECL_GCVT=1;
-  HAVE_DECL_GETLOADAVG=1;
-  HAVE_GETSUBOPT=1;
-  HAVE_GRANTPT=1;
-  HAVE_INITSTATE=1;
-  HAVE_DECL_INITSTATE=1;
-  HAVE_MBTOWC=1;
-  HAVE_MKDTEMP=1;
-  HAVE_MKOSTEMP=1;
-  HAVE_MKOSTEMPS=1;
-  HAVE_MKSTEMP=1;
-  HAVE_MKSTEMPS=1;
-  HAVE_POSIX_MEMALIGN=1;
-  HAVE_POSIX_OPENPT=1;
-  HAVE_PTSNAME=1;
-  HAVE_PTSNAME_R=1;
-  HAVE_QSORT_R=1;
-  HAVE_RANDOM=1;
-  HAVE_RANDOM_H=1;
-  HAVE_RANDOM_R=1;
-  HAVE_REALLOCARRAY=1;
-  HAVE_REALPATH=1;
-  HAVE_RPMATCH=1;
-  HAVE_SECURE_GETENV=1;
-  HAVE_SETENV=1;
-  HAVE_DECL_SETENV=1;
-  HAVE_SETSTATE=1;
-  HAVE_DECL_SETSTATE=1;
-  HAVE_STRTOD=1;
-  HAVE_STRTOL=1;
-  HAVE_STRTOLD=1;
-  HAVE_STRTOLL=1;
-  HAVE_STRTOUL=1;
-  HAVE_STRTOULL=1;
-  HAVE_STRUCT_RANDOM_DATA=1;
-  HAVE_SYS_LOADAVG_H=0;
-  HAVE_UNLOCKPT=1;
-  HAVE_DECL_UNSETENV=1;
-  REPLACE_ALIGNED_ALLOC=0;
-  REPLACE_CALLOC=0;
-  REPLACE_CANONICALIZE_FILE_NAME=0;
-  REPLACE_FREE=0;
-  REPLACE_INITSTATE=0;
-  REPLACE_MALLOC=0;
-  REPLACE_MBTOWC=0;
-  REPLACE_MKSTEMP=0;
-  REPLACE_POSIX_MEMALIGN=0;
-  REPLACE_PTSNAME=0;
-  REPLACE_PTSNAME_R=0;
-  REPLACE_PUTENV=0;
-  REPLACE_QSORT_R=0;
-  REPLACE_RANDOM=0;
-  REPLACE_RANDOM_R=0;
-  REPLACE_REALLOC=0;
-  REPLACE_REALLOCARRAY=0;
-  REPLACE_REALPATH=0;
-  REPLACE_SETENV=0;
-  REPLACE_SETSTATE=0;
-  REPLACE_STRTOD=0;
-  REPLACE_STRTOL=0;
-  REPLACE_STRTOLD=0;
-  REPLACE_STRTOLL=0;
-  REPLACE_STRTOUL=0;
-  REPLACE_STRTOULL=0;
-  REPLACE_UNSETENV=0;
-  REPLACE_WCTOMB=0;
+      if test "X$prefix" = "XNONE"; then
+    acl_final_prefix="$ac_default_prefix"
+  else
+    acl_final_prefix="$prefix"
+  fi
+  if test "X$exec_prefix" = "XNONE"; then
+    acl_final_exec_prefix='${prefix}'
+  else
+    acl_final_exec_prefix="$exec_prefix"
+  fi
+  acl_save_prefix="$prefix"
+  prefix="$acl_final_prefix"
+  eval acl_final_exec_prefix=\"$acl_final_exec_prefix\"
+  prefix="$acl_save_prefix"
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether malloc is ptrdiff_t safe" >&5
-printf %s "checking whether malloc is ptrdiff_t safe... " >&6; }
-if test ${gl_cv_malloc_ptrdiff+y}
+
+# Check whether --with-gnu-ld was given.
+if test ${with_gnu_ld+y}
 then :
-  printf %s "(cached) " >&6
+  withval=$with_gnu_ld; test "$withval" = no || with_gnu_ld=yes
 else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <stdint.h>
+  with_gnu_ld=no
+fi
 
-int
-main (void)
-{
-/* 64-bit ptrdiff_t is so wide that no practical platform
-               can exceed it.  */
-            #define WIDE_PTRDIFF (PTRDIFF_MAX >> 31 >> 31 != 0)
+# Prepare PATH_SEPARATOR.
+# The user is always right.
+if test "${PATH_SEPARATOR+set}" != set; then
+  # Determine PATH_SEPARATOR by trying to find /bin/sh in a PATH which
+  # contains only /bin. Note that ksh looks also at the FPATH variable,
+  # so we have to set that as well for the test.
+  PATH_SEPARATOR=:
+  (PATH='/bin;/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 \
+    && { (PATH='/bin:/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 \
+           || PATH_SEPARATOR=';'
+       }
+fi
 
-            /* On rare machines where size_t fits in ptrdiff_t there
-               is no problem.  */
-            #define NARROW_SIZE (SIZE_MAX <= PTRDIFF_MAX)
+if test -n "$LD"; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for ld" >&5
+printf %s "checking for ld... " >&6; }
+elif test "$GCC" = yes; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for ld used by $CC" >&5
+printf %s "checking for ld used by $CC... " >&6; }
+elif test "$with_gnu_ld" = yes; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for GNU ld" >&5
+printf %s "checking for GNU ld... " >&6; }
+else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for non-GNU ld" >&5
+printf %s "checking for non-GNU ld... " >&6; }
+fi
+if test -n "$LD"; then
+  # Let the user override the test with a path.
+  :
+else
+  if test ${acl_cv_path_LD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
-            /* glibc 2.30 and later malloc refuses to exceed ptrdiff_t
-               bounds even on 32-bit platforms.  We don't know which
-               non-glibc systems are safe.  */
-            #define KNOWN_SAFE (2 < __GLIBC__ + (30 <= __GLIBC_MINOR__))
+    acl_cv_path_LD= # Final result of this test
+    ac_prog=ld # Program to search in $PATH
+    if test "$GCC" = yes; then
+      # Check if gcc -print-prog-name=ld gives a path.
+      case $host in
+        *-*-mingw*)
+          # gcc leaves a trailing carriage return which upsets mingw
+          acl_output=`($CC -print-prog-name=ld) 2>&5 | tr -d '\015'` ;;
+        *)
+          acl_output=`($CC -print-prog-name=ld) 2>&5` ;;
+      esac
+      case $acl_output in
+        # Accept absolute paths.
+        [\\/]* | ?:[\\/]*)
+          re_direlt='/[^/][^/]*/\.\./'
+          # Canonicalize the pathname of ld
+          acl_output=`echo "$acl_output" | sed 's%\\\\%/%g'`
+          while echo "$acl_output" | grep "$re_direlt" > /dev/null 2>&1; do
+            acl_output=`echo $acl_output | sed "s%$re_direlt%/%"`
+          done
+          # Got the pathname. No search in PATH is needed.
+          acl_cv_path_LD="$acl_output"
+          ac_prog=
+          ;;
+        "")
+          # If it fails, then pretend we aren't using GCC.
+          ;;
+        *)
+          # If it is relative, then search for the first ld in PATH.
+          with_gnu_ld=unknown
+          ;;
+      esac
+    fi
+    if test -n "$ac_prog"; then
+      # Search for $ac_prog in $PATH.
+      acl_save_ifs="$IFS"; IFS=$PATH_SEPARATOR
+      for ac_dir in $PATH; do
+        IFS="$acl_save_ifs"
+        test -z "$ac_dir" && ac_dir=.
+        if test -f "$ac_dir/$ac_prog" || test -f "$ac_dir/$ac_prog$ac_exeext"; then
+          acl_cv_path_LD="$ac_dir/$ac_prog"
+          # Check to see if the program is GNU ld.  I'd rather use --version,
+          # but apparently some variants of GNU ld only accept -v.
+          # Break only if it was the GNU/non-GNU ld that we prefer.
+          case `"$acl_cv_path_LD" -v 2>&1 </dev/null` in
+            *GNU* | *'with BFD'*)
+              test "$with_gnu_ld" != no && break
+              ;;
+            *)
+              test "$with_gnu_ld" != yes && break
+              ;;
+          esac
+        fi
+      done
+      IFS="$acl_save_ifs"
+    fi
+    case $host in
+      *-*-aix*)
+        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __powerpc64__ || defined __LP64__
+                int ok;
+               #else
+                error fail
+               #endif
 
-            #if WIDE_PTRDIFF || NARROW_SIZE || KNOWN_SAFE
-              return 0;
-            #else
-              #error "malloc might not be ptrdiff_t safe"
-              syntax error
-            #endif
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  # The compiler produces 64-bit code. Add option '-b64' so that the
+           # linker groks 64-bit object files.
+           case "$acl_cv_path_LD " in
+             *" -b64 "*) ;;
+             *) acl_cv_path_LD="$acl_cv_path_LD -b64" ;;
+           esac
+
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+        ;;
+      sparc64-*-netbsd*)
+        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __sparcv9 || defined __arch64__
+                int ok;
+               #else
+                error fail
+               #endif
 
-  ;
-  return 0;
-}
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_malloc_ptrdiff=yes
+
 else $as_nop
-  gl_cv_malloc_ptrdiff=no
+  # The compiler produces 32-bit code. Add option '-m elf32_sparc'
+           # so that the linker groks 32-bit object files.
+           case "$acl_cv_path_LD " in
+             *" -m elf32_sparc "*) ;;
+             *) acl_cv_path_LD="$acl_cv_path_LD -m elf32_sparc" ;;
+           esac
+
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+        ;;
+    esac
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_malloc_ptrdiff" >&5
-printf "%s\n" "$gl_cv_malloc_ptrdiff" >&6; }
-
 
+  LD="$acl_cv_path_LD"
+fi
+if test -n "$LD"; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LD" >&5
+printf "%s\n" "$LD" >&6; }
+else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+  as_fn_error $? "no acceptable ld found in \$PATH" "$LINENO" 5
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking if the linker ($LD) is GNU ld" >&5
+printf %s "checking if the linker ($LD) is GNU ld... " >&6; }
+if test ${acl_cv_prog_gnu_ld+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  # I'd rather use --version here, but apparently some GNU lds only accept -v.
+case `$LD -v 2>&1 </dev/null` in
+*GNU* | *'with BFD'*)
+  acl_cv_prog_gnu_ld=yes
+  ;;
+*)
+  acl_cv_prog_gnu_ld=no
+  ;;
+esac
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $acl_cv_prog_gnu_ld" >&5
+printf "%s\n" "$acl_cv_prog_gnu_ld" >&6; }
+with_gnu_ld=$acl_cv_prog_gnu_ld
 
 
-  test "$gl_cv_malloc_ptrdiff" = yes || REPLACE_MALLOC=1
 
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether malloc, realloc, calloc set errno on failure" >&5
-printf %s "checking whether malloc, realloc, calloc set errno on failure... " >&6; }
-if test ${gl_cv_func_malloc_posix+y}
+                                                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for shared library run path origin" >&5
+printf %s "checking for shared library run path origin... " >&6; }
+if test ${acl_cv_rpath+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
 
-                                    case "$host_os" in
-        mingw*)
-          gl_cv_func_malloc_posix=no ;;
-        irix* | solaris*)
-
-          gl_cv_func_malloc_posix=no ;;
-        *)
-          gl_cv_func_malloc_posix=yes ;;
-      esac
+    CC="$CC" GCC="$GCC" LDFLAGS="$LDFLAGS" LD="$LD" with_gnu_ld="$with_gnu_ld" \
+    ${CONFIG_SHELL-/bin/sh} "$ac_aux_dir/config.rpath" "$host" > conftest.sh
+    . ./conftest.sh
+    rm -f ./conftest.sh
+    acl_cv_rpath=done
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_malloc_posix" >&5
-printf "%s\n" "$gl_cv_func_malloc_posix" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $acl_cv_rpath" >&5
+printf "%s\n" "$acl_cv_rpath" >&6; }
+  wl="$acl_cv_wl"
+  acl_libext="$acl_cv_libext"
+  acl_shlibext="$acl_cv_shlibext"
+  acl_libname_spec="$acl_cv_libname_spec"
+  acl_library_names_spec="$acl_cv_library_names_spec"
+  acl_hardcode_libdir_flag_spec="$acl_cv_hardcode_libdir_flag_spec"
+  acl_hardcode_libdir_separator="$acl_cv_hardcode_libdir_separator"
+  acl_hardcode_direct="$acl_cv_hardcode_direct"
+  acl_hardcode_minus_L="$acl_cv_hardcode_minus_L"
+    # Check whether --enable-rpath was given.
+if test ${enable_rpath+y}
+then :
+  enableval=$enable_rpath; :
+else $as_nop
+  enable_rpath=yes
+fi
 
 
 
 
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking 32-bit host C ABI" >&5
+printf %s "checking 32-bit host C ABI... " >&6; }
+if test ${gl_cv_host_cpu_c_abi_32bit+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test -n "$gl_cv_host_cpu_c_abi"; then
+       case "$gl_cv_host_cpu_c_abi" in
+         i386 | x86_64-x32 | arm | armhf | arm64-ilp32 | hppa | ia64-ilp32 | mips | mipsn32 | powerpc | riscv*-ilp32* | s390 | sparc)
+           gl_cv_host_cpu_c_abi_32bit=yes ;;
+         x86_64 | alpha | arm64 | hppa64 | ia64 | mips64 | powerpc64 | powerpc64-elfv2 | riscv*-lp64* | s390x | sparc64 )
+           gl_cv_host_cpu_c_abi_32bit=no ;;
+         *)
+           gl_cv_host_cpu_c_abi_32bit=unknown ;;
+       esac
+     else
+       case "$host_cpu" in
 
-  if test "$gl_cv_func_malloc_posix" = yes; then
+         # CPUs that only support a 32-bit ABI.
+         arc \
+         | bfin \
+         | cris* \
+         | csky \
+         | epiphany \
+         | ft32 \
+         | h8300 \
+         | m68k \
+         | microblaze | microblazeel \
+         | nds32 | nds32le | nds32be \
+         | nios2 | nios2eb | nios2el \
+         | or1k* \
+         | or32 \
+         | sh | sh1234 | sh1234elb \
+         | tic6x \
+         | xtensa* )
+           gl_cv_host_cpu_c_abi_32bit=yes
+           ;;
 
-printf "%s\n" "#define HAVE_MALLOC_POSIX 1" >>confdefs.h
+         # CPUs that only support a 64-bit ABI.
+         alpha | alphaev[4-8] | alphaev56 | alphapca5[67] | alphaev6[78] \
+         | mmix )
+           gl_cv_host_cpu_c_abi_32bit=no
+           ;;
 
-  else
-    REPLACE_MALLOC=1
-  fi
+         i[34567]86 )
+           gl_cv_host_cpu_c_abi_32bit=yes
+           ;;
 
+         x86_64 )
+           # On x86_64 systems, the C compiler may be generating code in one of
+           # these ABIs:
+           # - 64-bit instruction set, 64-bit pointers, 64-bit 'long': x86_64.
+           # - 64-bit instruction set, 64-bit pointers, 32-bit 'long': x86_64
+           #   with native Windows (mingw, MSVC).
+           # - 64-bit instruction set, 32-bit pointers, 32-bit 'long': x86_64-x32.
+           # - 32-bit instruction set, 32-bit pointers, 32-bit 'long': i386.
+           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if (defined __x86_64__ || defined __amd64__ \
+                       || defined _M_X64 || defined _M_AMD64) \
+                      && !(defined __ILP32__ || defined _ILP32)
+                   int ok;
+                  #else
+                   error fail
+                  #endif
 
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_host_cpu_c_abi_32bit=no
+else $as_nop
+  gl_cv_host_cpu_c_abi_32bit=yes
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+           ;;
 
+         arm* | aarch64 )
+           # Assume arm with EABI.
+           # On arm64 systems, the C compiler may be generating code in one of
+           # these ABIs:
+           # - aarch64 instruction set, 64-bit pointers, 64-bit 'long': arm64.
+           # - aarch64 instruction set, 32-bit pointers, 32-bit 'long': arm64-ilp32.
+           # - 32-bit instruction set, 32-bit pointers, 32-bit 'long': arm or armhf.
+           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __aarch64__ && !(defined __ILP32__ || defined _ILP32)
+                   int ok;
+                  #else
+                   error fail
+                  #endif
 
-  if test $REPLACE_MALLOC = 1; then
-    REPLACE_CALLOC=1
-  fi
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_host_cpu_c_abi_32bit=no
+else $as_nop
+  gl_cv_host_cpu_c_abi_32bit=yes
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+           ;;
 
+         hppa1.0 | hppa1.1 | hppa2.0* | hppa64 )
+           # On hppa, the C compiler may be generating 32-bit code or 64-bit
+           # code. In the latter case, it defines _LP64 and __LP64__.
+           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#ifdef __LP64__
+                   int ok;
+                  #else
+                   error fail
+                  #endif
 
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_host_cpu_c_abi_32bit=no
+else $as_nop
+  gl_cv_host_cpu_c_abi_32bit=yes
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+           ;;
 
-  GL_M4_GNULIB__EXIT=0
+         ia64* )
+           # On ia64 on HP-UX, the C compiler may be generating 64-bit code or
+           # 32-bit code. In the latter case, it defines _ILP32.
+           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#ifdef _ILP32
+                   int ok;
+                  #else
+                   error fail
+                  #endif
 
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_host_cpu_c_abi_32bit=yes
+else $as_nop
+  gl_cv_host_cpu_c_abi_32bit=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+           ;;
 
+         mips* )
+           # We should also check for (_MIPS_SZPTR == 64), but gcc keeps this
+           # at 32.
+           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined _MIPS_SZLONG && (_MIPS_SZLONG == 64)
+                   int ok;
+                  #else
+                   error fail
+                  #endif
 
-  GL_M4_GNULIB_ALIGNED_ALLOC=0
-
-
-
-  GL_M4_GNULIB_ATOLL=0
-
-
-
-  GL_M4_GNULIB_CALLOC_POSIX=0
-
-
-
-  GL_M4_GNULIB_CANONICALIZE_FILE_NAME=0
-
-
-
-  GL_M4_GNULIB_FREE_POSIX=0
-
-
-
-  GL_M4_GNULIB_GETLOADAVG=0
-
-
-
-  GL_M4_GNULIB_GETSUBOPT=0
-
-
-
-  GL_M4_GNULIB_GRANTPT=0
-
-
-
-  GL_M4_GNULIB_MALLOC_POSIX=0
-
-
-
-  GL_M4_GNULIB_MBTOWC=0
-
-
-
-  GL_M4_GNULIB_MKDTEMP=0
-
-
-
-  GL_M4_GNULIB_MKOSTEMP=0
-
-
-
-  GL_M4_GNULIB_MKOSTEMPS=0
-
-
-
-  GL_M4_GNULIB_MKSTEMP=0
-
-
-
-  GL_M4_GNULIB_MKSTEMPS=0
-
-
-
-  GL_M4_GNULIB_POSIX_MEMALIGN=0
-
-
-
-  GL_M4_GNULIB_POSIX_OPENPT=0
-
-
-
-  GL_M4_GNULIB_PTSNAME=0
-
-
-
-  GL_M4_GNULIB_PTSNAME_R=0
-
-
-
-  GL_M4_GNULIB_PUTENV=0
-
-
-
-  GL_M4_GNULIB_QSORT_R=0
-
-
-
-  GL_M4_GNULIB_RANDOM=0
-
-
-
-  GL_M4_GNULIB_RANDOM_R=0
-
-
-
-  GL_M4_GNULIB_REALLOCARRAY=0
-
-
-
-  GL_M4_GNULIB_REALLOC_POSIX=0
-
-
-
-  GL_M4_GNULIB_REALPATH=0
-
-
-
-  GL_M4_GNULIB_RPMATCH=0
-
-
-
-  GL_M4_GNULIB_SECURE_GETENV=0
-
-
-
-  GL_M4_GNULIB_SETENV=0
-
-
-
-  GL_M4_GNULIB_STRTOD=0
-
-
-
-  GL_M4_GNULIB_STRTOL=0
-
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_host_cpu_c_abi_32bit=no
+else $as_nop
+  gl_cv_host_cpu_c_abi_32bit=yes
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+           ;;
 
+         powerpc* )
+           # Different ABIs are in use on AIX vs. Mac OS X vs. Linux,*BSD.
+           # No need to distinguish them here; the caller may distinguish
+           # them based on the OS.
+           # On powerpc64 systems, the C compiler may still be generating
+           # 32-bit code. And on powerpc-ibm-aix systems, the C compiler may
+           # be generating 64-bit code.
+           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __powerpc64__ || defined __LP64__
+                   int ok;
+                  #else
+                   error fail
+                  #endif
 
-  GL_M4_GNULIB_STRTOLD=0
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_host_cpu_c_abi_32bit=no
+else $as_nop
+  gl_cv_host_cpu_c_abi_32bit=yes
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+           ;;
 
+         rs6000 )
+           gl_cv_host_cpu_c_abi_32bit=yes
+           ;;
 
+         riscv32 | riscv64 )
+           # There are 6 ABIs: ilp32, ilp32f, ilp32d, lp64, lp64f, lp64d.
+           # Size of 'long' and 'void *':
+           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __LP64__
+                    int ok;
+                  #else
+                    error fail
+                  #endif
 
-  GL_M4_GNULIB_STRTOLL=0
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_host_cpu_c_abi_32bit=no
+else $as_nop
+  gl_cv_host_cpu_c_abi_32bit=yes
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+           ;;
 
+         s390* )
+           # On s390x, the C compiler may be generating 64-bit (= s390x) code
+           # or 31-bit (= s390) code.
+           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __LP64__ || defined __s390x__
+                    int ok;
+                  #else
+                    error fail
+                  #endif
 
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_host_cpu_c_abi_32bit=no
+else $as_nop
+  gl_cv_host_cpu_c_abi_32bit=yes
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+           ;;
 
-  GL_M4_GNULIB_STRTOUL=0
+         sparc | sparc64 )
+           # UltraSPARCs running Linux have `uname -m` = "sparc64", but the
+           # C compiler still generates 32-bit code.
+           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __sparcv9 || defined __arch64__
+                   int ok;
+                  #else
+                   error fail
+                  #endif
 
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_host_cpu_c_abi_32bit=no
+else $as_nop
+  gl_cv_host_cpu_c_abi_32bit=yes
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+           ;;
 
+         *)
+           gl_cv_host_cpu_c_abi_32bit=unknown
+           ;;
+       esac
+     fi
 
-  GL_M4_GNULIB_STRTOULL=0
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_host_cpu_c_abi_32bit" >&5
+printf "%s\n" "$gl_cv_host_cpu_c_abi_32bit" >&6; }
 
+  HOST_CPU_C_ABI_32BIT="$gl_cv_host_cpu_c_abi_32bit"
 
 
-  GL_M4_GNULIB_SYSTEM_POSIX=0
 
 
 
-  GL_M4_GNULIB_UNLOCKPT=0
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for ELF binary format" >&5
+printf %s "checking for ELF binary format... " >&6; }
+if test ${gl_cv_elf+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#ifdef __ELF__
+        Extensible Linking Format
+        #endif
 
+_ACEOF
+if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
+  $EGREP "Extensible Linking Format" >/dev/null 2>&1
+then :
+  gl_cv_elf=yes
+else $as_nop
+  gl_cv_elf=no
+fi
+rm -rf conftest*
 
 
-  GL_M4_GNULIB_UNSETENV=0
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_elf" >&5
+printf "%s\n" "$gl_cv_elf" >&6; }
+  if test $gl_cv_elf = yes; then
+    # Extract the ELF class of a file (5th byte) in decimal.
+    # Cf. https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#File_header
+    if od -A x < /dev/null >/dev/null 2>/dev/null; then
+      # Use POSIX od.
+      func_elfclass ()
+      {
+        od -A n -t d1 -j 4 -N 1
+      }
+    else
+      # Use BSD hexdump.
+      func_elfclass ()
+      {
+        dd bs=1 count=1 skip=4 2>/dev/null | hexdump -e '1/1 "%3d "'
+        echo
+      }
+    fi
+    # Use 'expr', not 'test', to compare the values of func_elfclass, because on
+    # Solaris 11 OpenIndiana and Solaris 11 OmniOS, the result is 001 or 002,
+    # not 1 or 2.
+    case $HOST_CPU_C_ABI_32BIT in
+      yes)
+        # 32-bit ABI.
+        acl_is_expected_elfclass ()
+        {
+          expr "`func_elfclass | sed -e 's/[ 	]//g'`" = 1 > /dev/null
+        }
+        ;;
+      no)
+        # 64-bit ABI.
+        acl_is_expected_elfclass ()
+        {
+          expr "`func_elfclass | sed -e 's/[ 	]//g'`" = 2 > /dev/null
+        }
+        ;;
+      *)
+        # Unknown.
+        acl_is_expected_elfclass ()
+        {
+          :
+        }
+        ;;
+    esac
+  else
+    acl_is_expected_elfclass ()
+    {
+      :
+    }
+  fi
 
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for the common suffixes of directories in the library search path" >&5
+printf %s "checking for the common suffixes of directories in the library search path... " >&6; }
+if test ${acl_cv_libdirstems+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+            acl_libdirstem=lib
+     acl_libdirstem2=
+     acl_libdirstem3=
+     case "$host_os" in
+       solaris*)
+                                                      if test $HOST_CPU_C_ABI_32BIT = no; then
+           acl_libdirstem2=lib/64
+           case "$host_cpu" in
+             sparc*)        acl_libdirstem3=lib/sparcv9 ;;
+             i*86 | x86_64) acl_libdirstem3=lib/amd64 ;;
+           esac
+         fi
+         ;;
+       *)
+                                                                                 searchpath=`(LC_ALL=C $CC $CPPFLAGS $CFLAGS -print-search-dirs) 2>/dev/null \
+                     | sed -n -e 's,^libraries: ,,p' | sed -e 's,^=,,'`
+         if test $HOST_CPU_C_ABI_32BIT != no; then
+           # 32-bit or unknown ABI.
+           if test -d /usr/lib32; then
+             acl_libdirstem2=lib32
+           fi
+         fi
+         if test $HOST_CPU_C_ABI_32BIT != yes; then
+           # 64-bit or unknown ABI.
+           if test -d /usr/lib64; then
+             acl_libdirstem3=lib64
+           fi
+         fi
+         if test -n "$searchpath"; then
+           acl_save_IFS="${IFS= 	}"; IFS=":"
+           for searchdir in $searchpath; do
+             if test -d "$searchdir"; then
+               case "$searchdir" in
+                 */lib32/ | */lib32 ) acl_libdirstem2=lib32 ;;
+                 */lib64/ | */lib64 ) acl_libdirstem3=lib64 ;;
+                 */../ | */.. )
+                   # Better ignore directories of this form. They are misleading.
+                   ;;
+                 *) searchdir=`cd "$searchdir" && pwd`
+                    case "$searchdir" in
+                      */lib32 ) acl_libdirstem2=lib32 ;;
+                      */lib64 ) acl_libdirstem3=lib64 ;;
+                    esac ;;
+               esac
+             fi
+           done
+           IFS="$acl_save_IFS"
+           if test $HOST_CPU_C_ABI_32BIT = yes; then
+             # 32-bit ABI.
+             acl_libdirstem3=
+           fi
+           if test $HOST_CPU_C_ABI_32BIT = no; then
+             # 64-bit ABI.
+             acl_libdirstem2=
+           fi
+         fi
+         ;;
+     esac
+     test -n "$acl_libdirstem2" || acl_libdirstem2="$acl_libdirstem"
+     test -n "$acl_libdirstem3" || acl_libdirstem3="$acl_libdirstem"
+     acl_cv_libdirstems="$acl_libdirstem,$acl_libdirstem2,$acl_libdirstem3"
 
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $acl_cv_libdirstems" >&5
+printf "%s\n" "$acl_cv_libdirstems" >&6; }
+      acl_libdirstem=`echo "$acl_cv_libdirstems" | sed -e 's/,.*//'`
+  acl_libdirstem2=`echo "$acl_cv_libdirstems" | sed -e 's/^[^,]*,//' -e 's/,.*//'`
+  acl_libdirstem3=`echo "$acl_cv_libdirstems" | sed -e 's/^[^,]*,[^,]*,//' -e 's/,.*//'`
 
-  GL_M4_GNULIB_WCTOMB=0
 
 
+# Check whether --with-libsigsegv was given.
+if test ${with_libsigsegv+y}
+then :
+  withval=$with_libsigsegv;
+fi
 
-  GL_M4_GNULIB_MDA_ECVT=1
+  if test "$with_libsigsegv" = yes; then
 
 
 
-  GL_M4_GNULIB_MDA_FCVT=1
 
 
 
-  GL_M4_GNULIB_MDA_GCVT=1
 
 
 
-  GL_M4_GNULIB_MDA_MKTEMP=1
 
 
 
-  GL_M4_GNULIB_MDA_PUTENV=1
 
+    use_additional=yes
 
+  acl_save_prefix="$prefix"
+  prefix="$acl_final_prefix"
+  acl_save_exec_prefix="$exec_prefix"
+  exec_prefix="$acl_final_exec_prefix"
 
+    eval additional_includedir=\"$includedir\"
+    eval additional_libdir=\"$libdir\"
+    eval additional_libdir2=\"$exec_prefix/$acl_libdirstem2\"
+    eval additional_libdir3=\"$exec_prefix/$acl_libdirstem3\"
 
-         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether lstat correctly handles trailing slash" >&5
-printf %s "checking whether lstat correctly handles trailing slash... " >&6; }
-if test ${gl_cv_func_lstat_dereferences_slashed_symlink+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  rm -f conftest.sym conftest.file
-     echo >conftest.file
-     if test "$cross_compiling" = yes
-then :
-  case "$host_os" in
-          linux-* | linux)
-            # Guess yes on Linux systems.
-            gl_cv_func_lstat_dereferences_slashed_symlink="guessing yes" ;;
-          *-gnu* | gnu*)
-            # Guess yes on glibc systems.
-            gl_cv_func_lstat_dereferences_slashed_symlink="guessing yes" ;;
-          mingw*)
-            # Guess no on native Windows.
-            gl_cv_func_lstat_dereferences_slashed_symlink="guessing no" ;;
-          *)
-            # If we don't know, obey --enable-cross-guesses.
-            gl_cv_func_lstat_dereferences_slashed_symlink="$gl_cross_guess_normal" ;;
-        esac
+  exec_prefix="$acl_save_exec_prefix"
+  prefix="$acl_save_prefix"
 
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-$ac_includes_default
-int
-main (void)
-{
-struct stat sbuf;
-            if (symlink ("conftest.file", "conftest.sym") != 0)
-              return 1;
-            /* Linux will dereference the symlink and fail, as required by
-               POSIX.  That is better in the sense that it means we will not
-               have to compile and use the lstat wrapper.  */
-            return lstat ("conftest.sym/", &sbuf) == 0;
 
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
+# Check whether --with-libsigsegv-prefix was given.
+if test ${with_libsigsegv_prefix+y}
 then :
-  gl_cv_func_lstat_dereferences_slashed_symlink=yes
-else $as_nop
-  gl_cv_func_lstat_dereferences_slashed_symlink=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-
-     rm -f conftest.sym conftest.file
-
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_lstat_dereferences_slashed_symlink" >&5
-printf "%s\n" "$gl_cv_func_lstat_dereferences_slashed_symlink" >&6; }
-  case "$gl_cv_func_lstat_dereferences_slashed_symlink" in
-    *yes)
-
-printf "%s\n" "#define LSTAT_FOLLOWS_SLASHED_SYMLINK 1" >>confdefs.h
-
-      ;;
-  esac
-
+  withval=$with_libsigsegv_prefix;
+    if test "X$withval" = "Xno"; then
+      use_additional=no
+    else
+      if test "X$withval" = "X"; then
 
+  acl_save_prefix="$prefix"
+  prefix="$acl_final_prefix"
+  acl_save_exec_prefix="$exec_prefix"
+  exec_prefix="$acl_final_exec_prefix"
 
+          eval additional_includedir=\"$includedir\"
+          eval additional_libdir=\"$libdir\"
+          eval additional_libdir2=\"$exec_prefix/$acl_libdirstem2\"
+          eval additional_libdir3=\"$exec_prefix/$acl_libdirstem3\"
 
+  exec_prefix="$acl_save_exec_prefix"
+  prefix="$acl_save_prefix"
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether // is distinct from /" >&5
-printf %s "checking whether // is distinct from /... " >&6; }
-if test ${gl_cv_double_slash_root+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-   if test x"$cross_compiling" = xyes ; then
-        # When cross-compiling, there is no way to tell whether // is special
-        # short of a list of hosts.  However, the only known hosts to date
-        # that have a distinct // are Apollo DomainOS (too old to port to),
-        # Cygwin, and z/OS.  If anyone knows of another system for which // has
-        # special semantics and is distinct from /, please report it to
-        # <bug-gnulib@gnu.org>.
-        case $host in
-          *-cygwin | i370-ibm-openedition)
-            gl_cv_double_slash_root=yes ;;
-          *)
-            # Be optimistic and assume that / and // are the same when we
-            # don't know.
-            gl_cv_double_slash_root='unknown, assuming no' ;;
-        esac
       else
-        set x `ls -di / // 2>/dev/null`
-        if test "$2" = "$4" && wc //dev/null >/dev/null 2>&1; then
-          gl_cv_double_slash_root=no
-        else
-          gl_cv_double_slash_root=yes
-        fi
+        additional_includedir="$withval/include"
+        additional_libdir="$withval/$acl_libdirstem"
+        additional_libdir2="$withval/$acl_libdirstem2"
+        additional_libdir3="$withval/$acl_libdirstem3"
       fi
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_double_slash_root" >&5
-printf "%s\n" "$gl_cv_double_slash_root" >&6; }
-  if test "$gl_cv_double_slash_root" = yes; then
+    fi
 
-printf "%s\n" "#define DOUBLE_SLASH_IS_DISTINCT_ROOT 1" >>confdefs.h
+fi
+
+  if test "X$additional_libdir2" = "X$additional_libdir"; then
+    additional_libdir2=
+  fi
+  if test "X$additional_libdir3" = "X$additional_libdir"; then
+    additional_libdir3=
+  fi
+      LIBSIGSEGV=
+  LTLIBSIGSEGV=
+  INCSIGSEGV=
+  LIBSIGSEGV_PREFIX=
+      HAVE_LIBSIGSEGV=
+  rpathdirs=
+  ltrpathdirs=
+  names_already_handled=
+  names_next_round='sigsegv '
+  while test -n "$names_next_round"; do
+    names_this_round="$names_next_round"
+    names_next_round=
+    for name in $names_this_round; do
+      already_handled=
+      for n in $names_already_handled; do
+        if test "$n" = "$name"; then
+          already_handled=yes
+          break
+        fi
+      done
+      if test -z "$already_handled"; then
+        names_already_handled="$names_already_handled $name"
+                        uppername=`echo "$name" | sed -e 'y|abcdefghijklmnopqrstuvwxyz./+-|ABCDEFGHIJKLMNOPQRSTUVWXYZ____|'`
+        eval value=\"\$HAVE_LIB$uppername\"
+        if test -n "$value"; then
+          if test "$value" = yes; then
+            eval value=\"\$LIB$uppername\"
+            test -z "$value" || LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$value"
+            eval value=\"\$LTLIB$uppername\"
+            test -z "$value" || LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }$value"
+          else
+                                    :
+          fi
+        else
+                              found_dir=
+          found_la=
+          found_so=
+          found_a=
+          eval libname=\"$acl_libname_spec\"    # typically: libname=lib$name
+          if test -n "$acl_shlibext"; then
+            shrext=".$acl_shlibext"             # typically: shrext=.so
+          else
+            shrext=
+          fi
+          if test $use_additional = yes; then
+            for additional_libdir_variable in additional_libdir additional_libdir2 additional_libdir3; do
+              if test "X$found_dir" = "X"; then
+                eval dir=\$$additional_libdir_variable
+                if test -n "$dir"; then
+                                                      if test -n "$acl_shlibext"; then
+                    if test -f "$dir/$libname$shrext" && acl_is_expected_elfclass < "$dir/$libname$shrext"; then
+                      found_dir="$dir"
+                      found_so="$dir/$libname$shrext"
+                    else
+                      if test "$acl_library_names_spec" = '$libname$shrext$versuffix'; then
+                        ver=`(cd "$dir" && \
+                              for f in "$libname$shrext".*; do echo "$f"; done \
+                              | sed -e "s,^$libname$shrext\\\\.,," \
+                              | sort -t '.' -n -r -k1,1 -k2,2 -k3,3 -k4,4 -k5,5 \
+                              | sed 1q ) 2>/dev/null`
+                        if test -n "$ver" && test -f "$dir/$libname$shrext.$ver" && acl_is_expected_elfclass < "$dir/$libname$shrext.$ver"; then
+                          found_dir="$dir"
+                          found_so="$dir/$libname$shrext.$ver"
+                        fi
+                      else
+                        eval library_names=\"$acl_library_names_spec\"
+                        for f in $library_names; do
+                          if test -f "$dir/$f" && acl_is_expected_elfclass < "$dir/$f"; then
+                            found_dir="$dir"
+                            found_so="$dir/$f"
+                            break
+                          fi
+                        done
+                      fi
+                    fi
+                  fi
+                                    if test "X$found_dir" = "X"; then
+                    if test -f "$dir/$libname.$acl_libext" && ${AR-ar} -p "$dir/$libname.$acl_libext" | acl_is_expected_elfclass; then
+                      found_dir="$dir"
+                      found_a="$dir/$libname.$acl_libext"
+                    fi
+                  fi
+                  if test "X$found_dir" != "X"; then
+                    if test -f "$dir/$libname.la"; then
+                      found_la="$dir/$libname.la"
+                    fi
+                  fi
+                fi
+              fi
+            done
+          fi
+          if test "X$found_dir" = "X"; then
+            for x in $LDFLAGS $LTLIBSIGSEGV; do
+
+  acl_save_prefix="$prefix"
+  prefix="$acl_final_prefix"
+  acl_save_exec_prefix="$exec_prefix"
+  exec_prefix="$acl_final_exec_prefix"
+  eval x=\"$x\"
+  exec_prefix="$acl_save_exec_prefix"
+  prefix="$acl_save_prefix"
+
+              case "$x" in
+                -L*)
+                  dir=`echo "X$x" | sed -e 's/^X-L//'`
+                                    if test -n "$acl_shlibext"; then
+                    if test -f "$dir/$libname$shrext" && acl_is_expected_elfclass < "$dir/$libname$shrext"; then
+                      found_dir="$dir"
+                      found_so="$dir/$libname$shrext"
+                    else
+                      if test "$acl_library_names_spec" = '$libname$shrext$versuffix'; then
+                        ver=`(cd "$dir" && \
+                              for f in "$libname$shrext".*; do echo "$f"; done \
+                              | sed -e "s,^$libname$shrext\\\\.,," \
+                              | sort -t '.' -n -r -k1,1 -k2,2 -k3,3 -k4,4 -k5,5 \
+                              | sed 1q ) 2>/dev/null`
+                        if test -n "$ver" && test -f "$dir/$libname$shrext.$ver" && acl_is_expected_elfclass < "$dir/$libname$shrext.$ver"; then
+                          found_dir="$dir"
+                          found_so="$dir/$libname$shrext.$ver"
+                        fi
+                      else
+                        eval library_names=\"$acl_library_names_spec\"
+                        for f in $library_names; do
+                          if test -f "$dir/$f" && acl_is_expected_elfclass < "$dir/$f"; then
+                            found_dir="$dir"
+                            found_so="$dir/$f"
+                            break
+                          fi
+                        done
+                      fi
+                    fi
+                  fi
+                                    if test "X$found_dir" = "X"; then
+                    if test -f "$dir/$libname.$acl_libext" && ${AR-ar} -p "$dir/$libname.$acl_libext" | acl_is_expected_elfclass; then
+                      found_dir="$dir"
+                      found_a="$dir/$libname.$acl_libext"
+                    fi
+                  fi
+                  if test "X$found_dir" != "X"; then
+                    if test -f "$dir/$libname.la"; then
+                      found_la="$dir/$libname.la"
+                    fi
+                  fi
+                  ;;
+              esac
+              if test "X$found_dir" != "X"; then
+                break
+              fi
+            done
+          fi
+          if test "X$found_dir" != "X"; then
+                        LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }-L$found_dir -l$name"
+            if test "X$found_so" != "X"; then
+                                                        if test "$enable_rpath" = no \
+                 || test "X$found_dir" = "X/usr/$acl_libdirstem" \
+                 || test "X$found_dir" = "X/usr/$acl_libdirstem2" \
+                 || test "X$found_dir" = "X/usr/$acl_libdirstem3"; then
+                                LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$found_so"
+              else
+                                                                                haveit=
+                for x in $ltrpathdirs; do
+                  if test "X$x" = "X$found_dir"; then
+                    haveit=yes
+                    break
+                  fi
+                done
+                if test -z "$haveit"; then
+                  ltrpathdirs="$ltrpathdirs $found_dir"
+                fi
+                                if test "$acl_hardcode_direct" = yes; then
+                                                      LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$found_so"
+                else
+                  if test -n "$acl_hardcode_libdir_flag_spec" && test "$acl_hardcode_minus_L" = no; then
+                                                            LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$found_so"
+                                                            haveit=
+                    for x in $rpathdirs; do
+                      if test "X$x" = "X$found_dir"; then
+                        haveit=yes
+                        break
+                      fi
+                    done
+                    if test -z "$haveit"; then
+                      rpathdirs="$rpathdirs $found_dir"
+                    fi
+                  else
+                                                                                haveit=
+                    for x in $LDFLAGS $LIBSIGSEGV; do
+
+  acl_save_prefix="$prefix"
+  prefix="$acl_final_prefix"
+  acl_save_exec_prefix="$exec_prefix"
+  exec_prefix="$acl_final_exec_prefix"
+  eval x=\"$x\"
+  exec_prefix="$acl_save_exec_prefix"
+  prefix="$acl_save_prefix"
+
+                      if test "X$x" = "X-L$found_dir"; then
+                        haveit=yes
+                        break
+                      fi
+                    done
+                    if test -z "$haveit"; then
+                      LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }-L$found_dir"
+                    fi
+                    if test "$acl_hardcode_minus_L" != no; then
+                                                                                        LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$found_so"
+                    else
+                                                                                                                                                                                LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }-l$name"
+                    fi
+                  fi
+                fi
+              fi
+            else
+              if test "X$found_a" != "X"; then
+                                LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$found_a"
+              else
+                                                LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }-L$found_dir -l$name"
+              fi
+            fi
+                        additional_includedir=
+            case "$found_dir" in
+              */$acl_libdirstem | */$acl_libdirstem/)
+                basedir=`echo "X$found_dir" | sed -e 's,^X,,' -e "s,/$acl_libdirstem/"'*$,,'`
+                if test "$name" = 'sigsegv'; then
+                  LIBSIGSEGV_PREFIX="$basedir"
+                fi
+                additional_includedir="$basedir/include"
+                ;;
+              */$acl_libdirstem2 | */$acl_libdirstem2/)
+                basedir=`echo "X$found_dir" | sed -e 's,^X,,' -e "s,/$acl_libdirstem2/"'*$,,'`
+                if test "$name" = 'sigsegv'; then
+                  LIBSIGSEGV_PREFIX="$basedir"
+                fi
+                additional_includedir="$basedir/include"
+                ;;
+              */$acl_libdirstem3 | */$acl_libdirstem3/)
+                basedir=`echo "X$found_dir" | sed -e 's,^X,,' -e "s,/$acl_libdirstem3/"'*$,,'`
+                if test "$name" = 'sigsegv'; then
+                  LIBSIGSEGV_PREFIX="$basedir"
+                fi
+                additional_includedir="$basedir/include"
+                ;;
+            esac
+            if test "X$additional_includedir" != "X"; then
+                                                                                                                if test "X$additional_includedir" != "X/usr/include"; then
+                haveit=
+                if test "X$additional_includedir" = "X/usr/local/include"; then
+                  if test -n "$GCC"; then
+                    case $host_os in
+                      linux* | gnu* | k*bsd*-gnu) haveit=yes;;
+                    esac
+                  fi
+                fi
+                if test -z "$haveit"; then
+                  for x in $CPPFLAGS $INCSIGSEGV; do
+
+  acl_save_prefix="$prefix"
+  prefix="$acl_final_prefix"
+  acl_save_exec_prefix="$exec_prefix"
+  exec_prefix="$acl_final_exec_prefix"
+  eval x=\"$x\"
+  exec_prefix="$acl_save_exec_prefix"
+  prefix="$acl_save_prefix"
+
+                    if test "X$x" = "X-I$additional_includedir"; then
+                      haveit=yes
+                      break
+                    fi
+                  done
+                  if test -z "$haveit"; then
+                    if test -d "$additional_includedir"; then
+                                            INCSIGSEGV="${INCSIGSEGV}${INCSIGSEGV:+ }-I$additional_includedir"
+                    fi
+                  fi
+                fi
+              fi
+            fi
+                        if test -n "$found_la"; then
+                                                        save_libdir="$libdir"
+              case "$found_la" in
+                */* | *\\*) . "$found_la" ;;
+                *) . "./$found_la" ;;
+              esac
+              libdir="$save_libdir"
+                            for dep in $dependency_libs; do
+                case "$dep" in
+                  -L*)
+                    dependency_libdir=`echo "X$dep" | sed -e 's/^X-L//'`
+                                                                                                                                                                if test "X$dependency_libdir" != "X/usr/$acl_libdirstem" \
+                       && test "X$dependency_libdir" != "X/usr/$acl_libdirstem2" \
+                       && test "X$dependency_libdir" != "X/usr/$acl_libdirstem3"; then
+                      haveit=
+                      if test "X$dependency_libdir" = "X/usr/local/$acl_libdirstem" \
+                         || test "X$dependency_libdir" = "X/usr/local/$acl_libdirstem2" \
+                         || test "X$dependency_libdir" = "X/usr/local/$acl_libdirstem3"; then
+                        if test -n "$GCC"; then
+                          case $host_os in
+                            linux* | gnu* | k*bsd*-gnu) haveit=yes;;
+                          esac
+                        fi
+                      fi
+                      if test -z "$haveit"; then
+                        haveit=
+                        for x in $LDFLAGS $LIBSIGSEGV; do
+
+  acl_save_prefix="$prefix"
+  prefix="$acl_final_prefix"
+  acl_save_exec_prefix="$exec_prefix"
+  exec_prefix="$acl_final_exec_prefix"
+  eval x=\"$x\"
+  exec_prefix="$acl_save_exec_prefix"
+  prefix="$acl_save_prefix"
+
+                          if test "X$x" = "X-L$dependency_libdir"; then
+                            haveit=yes
+                            break
+                          fi
+                        done
+                        if test -z "$haveit"; then
+                          if test -d "$dependency_libdir"; then
+                                                        LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }-L$dependency_libdir"
+                          fi
+                        fi
+                        haveit=
+                        for x in $LDFLAGS $LTLIBSIGSEGV; do
+
+  acl_save_prefix="$prefix"
+  prefix="$acl_final_prefix"
+  acl_save_exec_prefix="$exec_prefix"
+  exec_prefix="$acl_final_exec_prefix"
+  eval x=\"$x\"
+  exec_prefix="$acl_save_exec_prefix"
+  prefix="$acl_save_prefix"
+
+                          if test "X$x" = "X-L$dependency_libdir"; then
+                            haveit=yes
+                            break
+                          fi
+                        done
+                        if test -z "$haveit"; then
+                          if test -d "$dependency_libdir"; then
+                                                        LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }-L$dependency_libdir"
+                          fi
+                        fi
+                      fi
+                    fi
+                    ;;
+                  -R*)
+                    dir=`echo "X$dep" | sed -e 's/^X-R//'`
+                    if test "$enable_rpath" != no; then
+                                                                  haveit=
+                      for x in $rpathdirs; do
+                        if test "X$x" = "X$dir"; then
+                          haveit=yes
+                          break
+                        fi
+                      done
+                      if test -z "$haveit"; then
+                        rpathdirs="$rpathdirs $dir"
+                      fi
+                                                                  haveit=
+                      for x in $ltrpathdirs; do
+                        if test "X$x" = "X$dir"; then
+                          haveit=yes
+                          break
+                        fi
+                      done
+                      if test -z "$haveit"; then
+                        ltrpathdirs="$ltrpathdirs $dir"
+                      fi
+                    fi
+                    ;;
+                  -l*)
+                                                                                                                                                                dep=`echo "X$dep" | sed -e 's/^X-l//'`
+                    if test "X$dep" != Xc \
+                       || case $host_os in
+                            linux* | gnu* | k*bsd*-gnu) false ;;
+                            *)                          true ;;
+                          esac; then
+                      names_next_round="$names_next_round $dep"
+                    fi
+                    ;;
+                  *.la)
+                                                                                names_next_round="$names_next_round "`echo "X$dep" | sed -e 's,^X.*/,,' -e 's,^lib,,' -e 's,\.la$,,'`
+                    ;;
+                  *)
+                                        LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$dep"
+                    LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }$dep"
+                    ;;
+                esac
+              done
+            fi
+          else
+                                                            LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }-l$name"
+            LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }-l$name"
+          fi
+        fi
+      fi
+    done
+  done
+  if test "X$rpathdirs" != "X"; then
+    if test -n "$acl_hardcode_libdir_separator"; then
+                        alldirs=
+      for found_dir in $rpathdirs; do
+        alldirs="${alldirs}${alldirs:+$acl_hardcode_libdir_separator}$found_dir"
+      done
+            acl_save_libdir="$libdir"
+      libdir="$alldirs"
+      eval flag=\"$acl_hardcode_libdir_flag_spec\"
+      libdir="$acl_save_libdir"
+      LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$flag"
+    else
+            for found_dir in $rpathdirs; do
+        acl_save_libdir="$libdir"
+        libdir="$found_dir"
+        eval flag=\"$acl_hardcode_libdir_flag_spec\"
+        libdir="$acl_save_libdir"
+        LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$flag"
+      done
+    fi
+  fi
+  if test "X$ltrpathdirs" != "X"; then
+            for found_dir in $ltrpathdirs; do
+      LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }-R$found_dir"
+    done
+  fi
+
+
+
+
+
+
+        ac_save_CPPFLAGS="$CPPFLAGS"
+
+  for element in $INCSIGSEGV; do
+    haveit=
+    for x in $CPPFLAGS; do
+
+  acl_save_prefix="$prefix"
+  prefix="$acl_final_prefix"
+  acl_save_exec_prefix="$exec_prefix"
+  exec_prefix="$acl_final_exec_prefix"
+  eval x=\"$x\"
+  exec_prefix="$acl_save_exec_prefix"
+  prefix="$acl_save_prefix"
+
+      if test "X$x" = "X$element"; then
+        haveit=yes
+        break
+      fi
+    done
+    if test -z "$haveit"; then
+      CPPFLAGS="${CPPFLAGS}${CPPFLAGS:+ }$element"
+    fi
+  done
+
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libsigsegv" >&5
+printf %s "checking for libsigsegv... " >&6; }
+if test ${ac_cv_libsigsegv+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+
+    ac_save_LIBS="$LIBS"
+                                case " $LIBSIGSEGV" in
+      *" -l"*) LIBS="$LIBS $LIBSIGSEGV" ;;
+      *)       LIBS="$LIBSIGSEGV $LIBS" ;;
+    esac
+    cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <sigsegv.h>
+int
+main (void)
+{
+sigsegv_deinstall_handler();
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"
+then :
+  ac_cv_libsigsegv=yes
+else $as_nop
+  ac_cv_libsigsegv='no, consider installing GNU libsigsegv'
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+    LIBS="$ac_save_LIBS"
+
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_libsigsegv" >&5
+printf "%s\n" "$ac_cv_libsigsegv" >&6; }
+  if test "$ac_cv_libsigsegv" = yes; then
+    HAVE_LIBSIGSEGV=yes
+
+printf "%s\n" "#define HAVE_LIBSIGSEGV 1" >>confdefs.h
+
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking how to link with libsigsegv" >&5
+printf %s "checking how to link with libsigsegv... " >&6; }
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LIBSIGSEGV" >&5
+printf "%s\n" "$LIBSIGSEGV" >&6; }
+  else
+    HAVE_LIBSIGSEGV=no
+            CPPFLAGS="$ac_save_CPPFLAGS"
+    LIBSIGSEGV=
+    LTLIBSIGSEGV=
+    LIBSIGSEGV_PREFIX=
+  fi
+
+
+
+
+
+
+
+    gl_cv_lib_sigsegv="$ac_cv_libsigsegv"
+
+    gl_sigsegv_uses_libsigsegv="$gl_cv_lib_sigsegv"
+  else
+    gl_sigsegv_uses_libsigsegv=no
+  fi
+
+
+    HAVE__EXIT=1;
+  HAVE_ALIGNED_ALLOC=1;
+  HAVE_ATOLL=1;
+  HAVE_CANONICALIZE_FILE_NAME=1;
+  HAVE_DECL_ECVT=1;
+  HAVE_DECL_FCVT=1;
+  HAVE_DECL_GCVT=1;
+  HAVE_DECL_GETLOADAVG=1;
+  HAVE_GETSUBOPT=1;
+  HAVE_GRANTPT=1;
+  HAVE_INITSTATE=1;
+  HAVE_DECL_INITSTATE=1;
+  HAVE_MBTOWC=1;
+  HAVE_MKDTEMP=1;
+  HAVE_MKOSTEMP=1;
+  HAVE_MKOSTEMPS=1;
+  HAVE_MKSTEMP=1;
+  HAVE_MKSTEMPS=1;
+  HAVE_POSIX_MEMALIGN=1;
+  HAVE_POSIX_OPENPT=1;
+  HAVE_PTSNAME=1;
+  HAVE_PTSNAME_R=1;
+  HAVE_QSORT_R=1;
+  HAVE_RANDOM=1;
+  HAVE_RANDOM_H=1;
+  HAVE_RANDOM_R=1;
+  HAVE_REALLOCARRAY=1;
+  HAVE_REALPATH=1;
+  HAVE_RPMATCH=1;
+  HAVE_SECURE_GETENV=1;
+  HAVE_SETENV=1;
+  HAVE_DECL_SETENV=1;
+  HAVE_SETSTATE=1;
+  HAVE_DECL_SETSTATE=1;
+  HAVE_STRTOD=1;
+  HAVE_STRTOL=1;
+  HAVE_STRTOLD=1;
+  HAVE_STRTOLL=1;
+  HAVE_STRTOUL=1;
+  HAVE_STRTOULL=1;
+  HAVE_STRUCT_RANDOM_DATA=1;
+  HAVE_SYS_LOADAVG_H=0;
+  HAVE_UNLOCKPT=1;
+  HAVE_DECL_UNSETENV=1;
+  REPLACE_ALIGNED_ALLOC=0;
+  REPLACE_CALLOC=0;
+  REPLACE_CANONICALIZE_FILE_NAME=0;
+  REPLACE_FREE=0;
+  REPLACE_INITSTATE=0;
+  REPLACE_MALLOC=0;
+  REPLACE_MBTOWC=0;
+  REPLACE_MKSTEMP=0;
+  REPLACE_POSIX_MEMALIGN=0;
+  REPLACE_PTSNAME=0;
+  REPLACE_PTSNAME_R=0;
+  REPLACE_PUTENV=0;
+  REPLACE_QSORT_R=0;
+  REPLACE_RANDOM=0;
+  REPLACE_RANDOM_R=0;
+  REPLACE_REALLOC=0;
+  REPLACE_REALLOCARRAY=0;
+  REPLACE_REALPATH=0;
+  REPLACE_SETENV=0;
+  REPLACE_SETSTATE=0;
+  REPLACE_STRTOD=0;
+  REPLACE_STRTOL=0;
+  REPLACE_STRTOLD=0;
+  REPLACE_STRTOLL=0;
+  REPLACE_STRTOUL=0;
+  REPLACE_STRTOULL=0;
+  REPLACE_UNSETENV=0;
+  REPLACE_WCTOMB=0;
+
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether malloc is ptrdiff_t safe" >&5
+printf %s "checking whether malloc is ptrdiff_t safe... " >&6; }
+if test ${gl_cv_malloc_ptrdiff+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <stdint.h>
+
+int
+main (void)
+{
+/* 64-bit ptrdiff_t is so wide that no practical platform
+               can exceed it.  */
+            #define WIDE_PTRDIFF (PTRDIFF_MAX >> 31 >> 31 != 0)
+
+            /* On rare machines where size_t fits in ptrdiff_t there
+               is no problem.  */
+            #define NARROW_SIZE (SIZE_MAX <= PTRDIFF_MAX)
+
+            /* glibc 2.30 and later malloc refuses to exceed ptrdiff_t
+               bounds even on 32-bit platforms.  We don't know which
+               non-glibc systems are safe.  */
+            #define KNOWN_SAFE (2 < __GLIBC__ + (30 <= __GLIBC_MINOR__))
+
+            #if WIDE_PTRDIFF || NARROW_SIZE || KNOWN_SAFE
+              return 0;
+            #else
+              #error "malloc might not be ptrdiff_t safe"
+              syntax error
+            #endif
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_malloc_ptrdiff=yes
+else $as_nop
+  gl_cv_malloc_ptrdiff=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_malloc_ptrdiff" >&5
+printf "%s\n" "$gl_cv_malloc_ptrdiff" >&6; }
+
+
+
+
+  test "$gl_cv_malloc_ptrdiff" = yes || REPLACE_MALLOC=1
+
+
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether malloc, realloc, calloc set errno on failure" >&5
+printf %s "checking whether malloc, realloc, calloc set errno on failure... " >&6; }
+if test ${gl_cv_func_malloc_posix+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+
+                                    case "$host_os" in
+        mingw*)
+          gl_cv_func_malloc_posix=no ;;
+        irix* | solaris*)
+
+          gl_cv_func_malloc_posix=no ;;
+        *)
+          gl_cv_func_malloc_posix=yes ;;
+      esac
+
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_malloc_posix" >&5
+printf "%s\n" "$gl_cv_func_malloc_posix" >&6; }
+
+
+
+
+
+  if test "$gl_cv_func_malloc_posix" = yes; then
+
+printf "%s\n" "#define HAVE_MALLOC_POSIX 1" >>confdefs.h
+
+  else
+    REPLACE_MALLOC=1
+  fi
+
+
+
+
+  if test $REPLACE_MALLOC = 1; then
+    REPLACE_CALLOC=1
+  fi
+
+
+
+  GL_M4_GNULIB__EXIT=0
+
+
+
+  GL_M4_GNULIB_ALIGNED_ALLOC=0
+
+
+
+  GL_M4_GNULIB_ATOLL=0
+
+
+
+  GL_M4_GNULIB_CALLOC_POSIX=0
+
+
+
+  GL_M4_GNULIB_CANONICALIZE_FILE_NAME=0
+
+
+
+  GL_M4_GNULIB_FREE_POSIX=0
+
+
+
+  GL_M4_GNULIB_GETLOADAVG=0
+
+
+
+  GL_M4_GNULIB_GETSUBOPT=0
+
+
+
+  GL_M4_GNULIB_GRANTPT=0
+
+
+
+  GL_M4_GNULIB_MALLOC_POSIX=0
+
+
+
+  GL_M4_GNULIB_MBTOWC=0
+
+
+
+  GL_M4_GNULIB_MKDTEMP=0
+
+
+
+  GL_M4_GNULIB_MKOSTEMP=0
+
+
+
+  GL_M4_GNULIB_MKOSTEMPS=0
+
+
+
+  GL_M4_GNULIB_MKSTEMP=0
+
+
+
+  GL_M4_GNULIB_MKSTEMPS=0
+
+
+
+  GL_M4_GNULIB_POSIX_MEMALIGN=0
+
+
+
+  GL_M4_GNULIB_POSIX_OPENPT=0
+
+
+
+  GL_M4_GNULIB_PTSNAME=0
+
+
+
+  GL_M4_GNULIB_PTSNAME_R=0
+
+
+
+  GL_M4_GNULIB_PUTENV=0
+
+
+
+  GL_M4_GNULIB_QSORT_R=0
+
+
+
+  GL_M4_GNULIB_RANDOM=0
+
+
+
+  GL_M4_GNULIB_RANDOM_R=0
+
+
+
+  GL_M4_GNULIB_REALLOCARRAY=0
+
+
+
+  GL_M4_GNULIB_REALLOC_POSIX=0
+
+
+
+  GL_M4_GNULIB_REALPATH=0
+
+
+
+  GL_M4_GNULIB_RPMATCH=0
+
+
+
+  GL_M4_GNULIB_SECURE_GETENV=0
+
+
+
+  GL_M4_GNULIB_SETENV=0
+
+
+
+  GL_M4_GNULIB_STRTOD=0
+
+
+
+  GL_M4_GNULIB_STRTOL=0
+
+
+
+  GL_M4_GNULIB_STRTOLD=0
+
+
+
+  GL_M4_GNULIB_STRTOLL=0
+
+
+
+  GL_M4_GNULIB_STRTOUL=0
+
+
+
+  GL_M4_GNULIB_STRTOULL=0
+
+
+
+  GL_M4_GNULIB_SYSTEM_POSIX=0
+
+
+
+  GL_M4_GNULIB_UNLOCKPT=0
+
+
+
+  GL_M4_GNULIB_UNSETENV=0
+
+
+
+  GL_M4_GNULIB_WCTOMB=0
+
+
+
+  GL_M4_GNULIB_MDA_ECVT=1
+
+
+
+  GL_M4_GNULIB_MDA_FCVT=1
+
+
+
+  GL_M4_GNULIB_MDA_GCVT=1
+
+
+
+  GL_M4_GNULIB_MDA_MKTEMP=1
+
+
+
+  GL_M4_GNULIB_MDA_PUTENV=1
+
+
+
+
+         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether lstat correctly handles trailing slash" >&5
+printf %s "checking whether lstat correctly handles trailing slash... " >&6; }
+if test ${gl_cv_func_lstat_dereferences_slashed_symlink+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  rm -f conftest.sym conftest.file
+     echo >conftest.file
+     if test "$cross_compiling" = yes
+then :
+  case "$host_os" in
+          linux-* | linux)
+            # Guess yes on Linux systems.
+            gl_cv_func_lstat_dereferences_slashed_symlink="guessing yes" ;;
+          *-gnu* | gnu*)
+            # Guess yes on glibc systems.
+            gl_cv_func_lstat_dereferences_slashed_symlink="guessing yes" ;;
+          mingw*)
+            # Guess no on native Windows.
+            gl_cv_func_lstat_dereferences_slashed_symlink="guessing no" ;;
+          *)
+            # If we don't know, obey --enable-cross-guesses.
+            gl_cv_func_lstat_dereferences_slashed_symlink="$gl_cross_guess_normal" ;;
+        esac
+
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main (void)
+{
+struct stat sbuf;
+            if (symlink ("conftest.file", "conftest.sym") != 0)
+              return 1;
+            /* Linux will dereference the symlink and fail, as required by
+               POSIX.  That is better in the sense that it means we will not
+               have to compile and use the lstat wrapper.  */
+            return lstat ("conftest.sym/", &sbuf) == 0;
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
+then :
+  gl_cv_func_lstat_dereferences_slashed_symlink=yes
+else $as_nop
+  gl_cv_func_lstat_dereferences_slashed_symlink=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
+
+     rm -f conftest.sym conftest.file
+
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_lstat_dereferences_slashed_symlink" >&5
+printf "%s\n" "$gl_cv_func_lstat_dereferences_slashed_symlink" >&6; }
+  case "$gl_cv_func_lstat_dereferences_slashed_symlink" in
+    *yes)
+
+printf "%s\n" "#define LSTAT_FOLLOWS_SLASHED_SYMLINK 1" >>confdefs.h
+
+      ;;
+  esac
+
+
+
+
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether // is distinct from /" >&5
+printf %s "checking whether // is distinct from /... " >&6; }
+if test ${gl_cv_double_slash_root+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+   if test x"$cross_compiling" = xyes ; then
+        # When cross-compiling, there is no way to tell whether // is special
+        # short of a list of hosts.  However, the only known hosts to date
+        # that have a distinct // are Apollo DomainOS (too old to port to),
+        # Cygwin, and z/OS.  If anyone knows of another system for which // has
+        # special semantics and is distinct from /, please report it to
+        # <bug-gnulib@gnu.org>.
+        case $host in
+          *-cygwin | i370-ibm-openedition)
+            gl_cv_double_slash_root=yes ;;
+          *)
+            # Be optimistic and assume that / and // are the same when we
+            # don't know.
+            gl_cv_double_slash_root='unknown, assuming no' ;;
+        esac
+      else
+        set x `ls -di / // 2>/dev/null`
+        if test "$2" = "$4" && wc //dev/null >/dev/null 2>&1; then
+          gl_cv_double_slash_root=no
+        else
+          gl_cv_double_slash_root=yes
+        fi
+      fi
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_double_slash_root" >&5
+printf "%s\n" "$gl_cv_double_slash_root" >&6; }
+  if test "$gl_cv_double_slash_root" = yes; then
+
+printf "%s\n" "#define DOUBLE_SLASH_IS_DISTINCT_ROOT 1" >>confdefs.h
 
   fi
 
 
-
-
-
+
+
+
      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether realpath works" >&5
 printf %s "checking whether realpath works... " >&6; }
 if test ${gl_cv_func_realpath_works+y}
@@ -13565,1529 +14842,527 @@
 
 
 
-  GL_M4_GNULIB_COPYSIGNL=0
-
-
-
-  GL_M4_GNULIB_COSF=0
-
-
-
-  GL_M4_GNULIB_COSL=0
-
-
-
-  GL_M4_GNULIB_COSHF=0
-
-
-
-  GL_M4_GNULIB_EXPF=0
-
-
-
-  GL_M4_GNULIB_EXPL=0
-
-
-
-  GL_M4_GNULIB_EXP2=0
-
-
-
-  GL_M4_GNULIB_EXP2F=0
-
-
-
-  GL_M4_GNULIB_EXP2L=0
-
-
-
-  GL_M4_GNULIB_EXPM1=0
-
-
-
-  GL_M4_GNULIB_EXPM1F=0
-
-
-
-  GL_M4_GNULIB_EXPM1L=0
-
-
-
-  GL_M4_GNULIB_FABSF=0
-
-
-
-  GL_M4_GNULIB_FABSL=0
-
-
-
-  GL_M4_GNULIB_FLOOR=0
-
-
-
-  GL_M4_GNULIB_FLOORF=0
-
-
-
-  GL_M4_GNULIB_FLOORL=0
-
-
-
-  GL_M4_GNULIB_FMA=0
-
-
-
-  GL_M4_GNULIB_FMAF=0
-
-
-
-  GL_M4_GNULIB_FMAL=0
-
-
-
-  GL_M4_GNULIB_FMOD=0
-
-
-
-  GL_M4_GNULIB_FMODF=0
-
-
-
-  GL_M4_GNULIB_FMODL=0
-
-
-
-  GL_M4_GNULIB_FREXPF=0
-
-
-
-  GL_M4_GNULIB_FREXP=0
-
-
-
-  GL_M4_GNULIB_FREXPL=0
-
-
-
-  GL_M4_GNULIB_HYPOT=0
-
-
-
-  GL_M4_GNULIB_HYPOTF=0
-
-
-
-  GL_M4_GNULIB_HYPOTL=0
-
-
-
-  GL_M4_GNULIB_ILOGB=0
-
-
-
-  GL_M4_GNULIB_ILOGBF=0
-
-
-
-  GL_M4_GNULIB_ILOGBL=0
-
-
-
-  GL_M4_GNULIB_ISFINITE=0
-
-
-
-  GL_M4_GNULIB_ISINF=0
-
-
-
-  GL_M4_GNULIB_ISNAN=0
-
-
-
-  GL_M4_GNULIB_ISNANF=0
-
-
-
-  GL_M4_GNULIB_ISNAND=0
-
-
-
-  GL_M4_GNULIB_ISNANL=0
-
-
-
-  GL_M4_GNULIB_LDEXPF=0
-
-
-
-  GL_M4_GNULIB_LDEXPL=0
-
-
-
-  GL_M4_GNULIB_LOG=0
-
-
-
-  GL_M4_GNULIB_LOGF=0
-
-
-
-  GL_M4_GNULIB_LOGL=0
-
-
-
-  GL_M4_GNULIB_LOG10=0
-
-
-
-  GL_M4_GNULIB_LOG10F=0
-
-
-
-  GL_M4_GNULIB_LOG10L=0
-
-
-
-  GL_M4_GNULIB_LOG1P=0
-
-
-
-  GL_M4_GNULIB_LOG1PF=0
-
-
-
-  GL_M4_GNULIB_LOG1PL=0
-
-
-
-  GL_M4_GNULIB_LOG2=0
-
-
-
-  GL_M4_GNULIB_LOG2F=0
-
-
-
-  GL_M4_GNULIB_LOG2L=0
-
-
-
-  GL_M4_GNULIB_LOGB=0
-
-
-
-  GL_M4_GNULIB_LOGBF=0
-
-
-
-  GL_M4_GNULIB_LOGBL=0
-
-
-
-  GL_M4_GNULIB_MODF=0
-
-
-
-  GL_M4_GNULIB_MODFF=0
-
-
-
-  GL_M4_GNULIB_MODFL=0
-
-
-
-  GL_M4_GNULIB_POWF=0
-
-
-
-  GL_M4_GNULIB_REMAINDER=0
-
-
-
-  GL_M4_GNULIB_REMAINDERF=0
-
-
-
-  GL_M4_GNULIB_REMAINDERL=0
-
-
-
-  GL_M4_GNULIB_RINT=0
-
-
-
-  GL_M4_GNULIB_RINTF=0
-
-
-
-  GL_M4_GNULIB_RINTL=0
-
-
-
-  GL_M4_GNULIB_ROUND=0
-
-
-
-  GL_M4_GNULIB_ROUNDF=0
-
-
-
-  GL_M4_GNULIB_ROUNDL=0
-
-
-
-  GL_M4_GNULIB_SIGNBIT=0
-
-
-
-  GL_M4_GNULIB_SINF=0
-
-
-
-  GL_M4_GNULIB_SINL=0
-
-
-
-  GL_M4_GNULIB_SINHF=0
-
-
-
-  GL_M4_GNULIB_SQRTF=0
-
-
-
-  GL_M4_GNULIB_SQRTL=0
-
-
-
-  GL_M4_GNULIB_TANF=0
-
-
-
-  GL_M4_GNULIB_TANL=0
-
-
-
-  GL_M4_GNULIB_TANHF=0
-
-
-
-  GL_M4_GNULIB_TRUNC=0
-
-
-
-  GL_M4_GNULIB_TRUNCF=0
-
-
-
-  GL_M4_GNULIB_TRUNCL=0
-
-
-
-  GL_M4_GNULIB_MDA_J0=1
-
-
-
-  GL_M4_GNULIB_MDA_J1=1
-
-
-
-  GL_M4_GNULIB_MDA_JN=1
-
-
-
-  GL_M4_GNULIB_MDA_Y0=1
-
-
-
-  GL_M4_GNULIB_MDA_Y1=1
-
-
-
-  GL_M4_GNULIB_MDA_YN=1
-
-
-
-
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether long double and double are the same" >&5
-printf %s "checking whether long double and double are the same... " >&6; }
-if test ${gl_cv_long_double_equals_double+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <float.h>
-int
-main (void)
-{
-typedef int check[sizeof (long double) == sizeof (double)
-                              && LDBL_MANT_DIG == DBL_MANT_DIG
-                              && LDBL_MAX_EXP == DBL_MAX_EXP
-                              && LDBL_MIN_EXP == DBL_MIN_EXP
-                              ? 1 : -1];
-
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  gl_cv_long_double_equals_double=yes
-else $as_nop
-  gl_cv_long_double_equals_double=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_long_double_equals_double" >&5
-printf "%s\n" "$gl_cv_long_double_equals_double" >&6; }
-  if test $gl_cv_long_double_equals_double = yes; then
-
-printf "%s\n" "#define HAVE_SAME_LONG_DOUBLE_AS_DOUBLE 1" >>confdefs.h
-
-    HAVE_SAME_LONG_DOUBLE_AS_DOUBLE=1
-  else
-    HAVE_SAME_LONG_DOUBLE_AS_DOUBLE=0
-  fi
-
-
-
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether stdin defaults to large file offsets" >&5
-printf %s "checking whether stdin defaults to large file offsets... " >&6; }
-if test ${gl_cv_var_stdin_large_offset+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <stdio.h>
-int
-main (void)
-{
-#if defined __SL64 && defined __SCLE /* cygwin */
-  /* Cygwin 1.5.24 and earlier fail to put stdin in 64-bit mode, making
-     fseeko/ftello needlessly fail.  This bug was fixed in 1.5.25, and
-     it is easier to do a version check than building a runtime test.  */
-# include <cygwin/version.h>
-# if CYGWIN_VERSION_DLL_COMBINED < CYGWIN_VERSION_DLL_MAKE_COMBINED (1005, 25)
-  choke me
-# endif
-#endif
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"
-then :
-  gl_cv_var_stdin_large_offset=yes
-else $as_nop
-  gl_cv_var_stdin_large_offset=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_var_stdin_large_offset" >&5
-printf "%s\n" "$gl_cv_var_stdin_large_offset" >&6; }
+  GL_M4_GNULIB_COPYSIGNL=0
 
 
 
+  GL_M4_GNULIB_COSF=0
 
 
-  case "$host_os" in
-    mingw*)
-                        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for 64-bit off_t" >&5
-printf %s "checking for 64-bit off_t... " >&6; }
-if test ${gl_cv_type_off_t_64+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sys/types.h>
-                int verify_off_t_size[sizeof (off_t) >= 8 ? 1 : -1];
 
-int
-main (void)
-{
+  GL_M4_GNULIB_COSL=0
 
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  gl_cv_type_off_t_64=yes
-else $as_nop
-  gl_cv_type_off_t_64=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_type_off_t_64" >&5
-printf "%s\n" "$gl_cv_type_off_t_64" >&6; }
-      if test $gl_cv_type_off_t_64 = no; then
-        WINDOWS_64_BIT_OFF_T=1
-      else
-        WINDOWS_64_BIT_OFF_T=0
-      fi
-                        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for 64-bit st_size" >&5
-printf %s "checking for 64-bit st_size... " >&6; }
-if test ${gl_cv_member_st_size_64+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sys/types.h>
-                struct stat buf;
-                int verify_st_size_size[sizeof (buf.st_size) >= 8 ? 1 : -1];
 
-int
-main (void)
-{
+  GL_M4_GNULIB_COSHF=0
 
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  gl_cv_member_st_size_64=yes
-else $as_nop
-  gl_cv_member_st_size_64=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_member_st_size_64" >&5
-printf "%s\n" "$gl_cv_member_st_size_64" >&6; }
-      if test $gl_cv_member_st_size_64 = no; then
-        WINDOWS_64_BIT_ST_SIZE=1
-      else
-        WINDOWS_64_BIT_ST_SIZE=0
-      fi
-      ;;
-    *)
-                                                      WINDOWS_64_BIT_OFF_T=0
-      WINDOWS_64_BIT_ST_SIZE=0
-      ;;
-  esac
 
+  GL_M4_GNULIB_EXPF=0
 
 
 
+  GL_M4_GNULIB_EXPL=0
 
 
 
+  GL_M4_GNULIB_EXP2=0
 
 
 
+  GL_M4_GNULIB_EXP2F=0
 
-printf "%s\n" "#define _USE_STD_STAT 1" >>confdefs.h
 
 
+  GL_M4_GNULIB_EXP2L=0
 
 
 
+  GL_M4_GNULIB_EXPM1=0
 
 
 
+  GL_M4_GNULIB_EXPM1F=0
 
 
-     if test $gl_cv_have_include_next = yes; then
-       gl_cv_next_sys_types_h='<'sys/types.h'>'
-     else
-       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking absolute name of <sys/types.h>" >&5
-printf %s "checking absolute name of <sys/types.h>... " >&6; }
-if test ${gl_cv_next_sys_types_h+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
+  GL_M4_GNULIB_EXPM1L=0
 
 
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sys/types.h>
-_ACEOF
-                case "$host_os" in
-    aix*) gl_absname_cpp="$ac_cpp -C" ;;
-    *)    gl_absname_cpp="$ac_cpp" ;;
-  esac
 
-  case "$host_os" in
-    mingw*)
-                                          gl_dirsep_regex='[/\\]'
-      ;;
-    *)
-      gl_dirsep_regex='\/'
-      ;;
-  esac
-      gl_make_literal_regex_sed='s,[]$^\\.*/[],\\&,g'
-  gl_header_literal_regex=`echo 'sys/types.h' \
-                           | sed -e "$gl_make_literal_regex_sed"`
-  gl_absolute_header_sed="/${gl_dirsep_regex}${gl_header_literal_regex}/"'{
-      s/.*"\(.*'"${gl_dirsep_regex}${gl_header_literal_regex}"'\)".*/\1/
-      s|^/[^/]|//&|
-      p
-      q
-    }'
+  GL_M4_GNULIB_FABSF=0
 
-        gl_cv_absolute_sys_types_h=`(eval "$gl_absname_cpp conftest.$ac_ext") 2>&5 |
-  sed -n "$gl_absolute_header_sed"`
 
-           gl_header=$gl_cv_absolute_sys_types_h
-           gl_cv_next_sys_types_h='"'$gl_header'"'
 
+  GL_M4_GNULIB_FABSL=0
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_next_sys_types_h" >&5
-printf "%s\n" "$gl_cv_next_sys_types_h" >&6; }
-     fi
-     NEXT_SYS_TYPES_H=$gl_cv_next_sys_types_h
 
-     if test $gl_cv_have_include_next = yes || test $gl_cv_have_include_next = buggy; then
-       # INCLUDE_NEXT_AS_FIRST_DIRECTIVE='include_next'
-       gl_next_as_first_directive='<'sys/types.h'>'
-     else
-       # INCLUDE_NEXT_AS_FIRST_DIRECTIVE='include'
-       gl_next_as_first_directive=$gl_cv_next_sys_types_h
-     fi
-     NEXT_AS_FIRST_DIRECTIVE_SYS_TYPES_H=$gl_next_as_first_directive
 
+  GL_M4_GNULIB_FLOOR=0
 
 
 
+  GL_M4_GNULIB_FLOORF=0
 
 
 
+  GL_M4_GNULIB_FLOORL=0
 
 
 
+  GL_M4_GNULIB_FMA=0
 
 
-    WINDOWS_STAT_INODES=0
 
+  GL_M4_GNULIB_FMAF=0
 
 
-ac_fn_check_decl "$LINENO" "fseeko" "ac_cv_have_decl_fseeko" "$ac_includes_default" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_fseeko" = xyes
-then :
-  ac_have_decl=1
-else $as_nop
-  ac_have_decl=0
-fi
-printf "%s\n" "#define HAVE_DECL_FSEEKO $ac_have_decl" >>confdefs.h
 
+  GL_M4_GNULIB_FMAL=0
 
 
 
+  GL_M4_GNULIB_FMOD=0
 
 
 
+  GL_M4_GNULIB_FMODF=0
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for fseeko" >&5
-printf %s "checking for fseeko... " >&6; }
-if test ${gl_cv_func_fseeko+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <stdio.h>
+  GL_M4_GNULIB_FMODL=0
 
-int
-main (void)
-{
-fseeko (stdin, 0, 0);
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"
-then :
-  gl_cv_func_fseeko=yes
-else $as_nop
-  gl_cv_func_fseeko=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_fseeko" >&5
-printf "%s\n" "$gl_cv_func_fseeko" >&6; }
 
+  GL_M4_GNULIB_FREXPF=0
 
-  if test $ac_cv_have_decl_fseeko = no; then
-    HAVE_DECL_FSEEKO=0
-  fi
 
-  if test $gl_cv_func_fseeko = no; then
-    HAVE_FSEEKO=0
-  else
-    if test $WINDOWS_64_BIT_OFF_T = 1; then
-      REPLACE_FSEEKO=1
-    fi
-    if test $gl_cv_var_stdin_large_offset = no; then
-      REPLACE_FSEEKO=1
-    fi
 
+  GL_M4_GNULIB_FREXP=0
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether fflush works on input streams" >&5
-printf %s "checking whether fflush works on input streams... " >&6; }
-if test ${gl_cv_func_fflush_stdin+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  echo hello world > conftest.txt
-     if test "$cross_compiling" = yes
-then :
-  case "$host_os" in
-                  # Guess no on native Windows.
-          mingw*) gl_cv_func_fflush_stdin="guessing no" ;;
-          *)      gl_cv_func_fflush_stdin=cross ;;
-        esac
 
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
+  GL_M4_GNULIB_FREXPL=0
 
-#include <stdio.h>
-#if HAVE_UNISTD_H
-# include <unistd.h>
-#else /* on Windows with MSVC */
-# include <io.h>
-#endif
 
 
-$gl_mda_defines
+  GL_M4_GNULIB_HYPOT=0
 
-int
-main (void)
-{
-FILE *f = fopen ("conftest.txt", "r");
-         char buffer[10];
-         int fd;
-         int c;
-         if (f == NULL)
-           return 1;
-         fd = fileno (f);
-         if (fd < 0 || fread (buffer, 1, 5, f) != 5)
-           { fclose (f); return 2; }
-         /* For deterministic results, ensure f read a bigger buffer.  */
-         if (lseek (fd, 0, SEEK_CUR) == 5)
-           { fclose (f); return 3; }
-         /* POSIX requires fflush-fseek to set file offset of fd.  This fails
-            on BSD systems and on mingw.  */
-         if (fflush (f) != 0 || fseek (f, 0, SEEK_CUR) != 0)
-           { fclose (f); return 4; }
-         if (lseek (fd, 0, SEEK_CUR) != 5)
-           { fclose (f); return 5; }
-         /* Verify behaviour of fflush after ungetc. See
-            <https://www.opengroup.org/austin/aardvark/latest/xshbug3.txt>  */
-         /* Verify behaviour of fflush after a backup ungetc.  This fails on
-            mingw.  */
-         c = fgetc (f);
-         ungetc (c, f);
-         fflush (f);
-         if (fgetc (f) != c)
-           { fclose (f); return 6; }
-         /* Verify behaviour of fflush after a non-backup ungetc.  This fails
-            on glibc 2.8 and on BSD systems.  */
-         c = fgetc (f);
-         ungetc ('@', f);
-         fflush (f);
-         if (fgetc (f) != c)
-           { fclose (f); return 7; }
-         fclose (f);
-         return 0;
 
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
-then :
-  gl_cv_func_fflush_stdin=yes
-else $as_nop
-  gl_cv_func_fflush_stdin=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
 
-     rm conftest.txt
+  GL_M4_GNULIB_HYPOTF=0
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_fflush_stdin" >&5
-printf "%s\n" "$gl_cv_func_fflush_stdin" >&6; }
-  case "$gl_cv_func_fflush_stdin" in
-    *yes) gl_func_fflush_stdin=1 ;;
-    *no)  gl_func_fflush_stdin=0 ;;
-    *)    gl_func_fflush_stdin='(-1)' ;;
-  esac
 
-printf "%s\n" "#define FUNC_FFLUSH_STDIN $gl_func_fflush_stdin" >>confdefs.h
 
+  GL_M4_GNULIB_HYPOTL=0
 
-      case "$gl_cv_func_fflush_stdin" in
-        *yes) ;;
-        *) REPLACE_FSEEKO=1 ;;
-      esac
 
-  fi
 
+  GL_M4_GNULIB_ILOGB=0
 
-    HAVE_FCHMODAT=1;
-  HAVE_FSTATAT=1;
-  HAVE_FUTIMENS=1;
-  HAVE_GETUMASK=1;
-  HAVE_LCHMOD=1;
-  HAVE_LSTAT=1;
-  HAVE_MKDIRAT=1;
-  HAVE_MKFIFO=1;
-  HAVE_MKFIFOAT=1;
-  HAVE_MKNOD=1;
-  HAVE_MKNODAT=1;
-  HAVE_UTIMENSAT=1;
-  REPLACE_FCHMODAT=0;
-  REPLACE_FSTAT=0;
-  REPLACE_FSTATAT=0;
-  REPLACE_FUTIMENS=0;
-  REPLACE_LSTAT=0;
-  REPLACE_MKDIR=0;
-  REPLACE_MKFIFO=0;
-  REPLACE_MKFIFOAT=0;
-  REPLACE_MKNOD=0;
-  REPLACE_MKNODAT=0;
-  REPLACE_STAT=0;
-  REPLACE_UTIMENSAT=0;
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether stat file-mode macros are broken" >&5
-printf %s "checking whether stat file-mode macros are broken... " >&6; }
-if test ${ac_cv_header_stat_broken+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sys/types.h>
-#include <sys/stat.h>
 
-#if defined S_ISBLK && defined S_IFDIR
-extern char c1[S_ISBLK (S_IFDIR) ? -1 : 1];
-#endif
+  GL_M4_GNULIB_ILOGBF=0
 
-#if defined S_ISBLK && defined S_IFCHR
-extern char c2[S_ISBLK (S_IFCHR) ? -1 : 1];
-#endif
 
-#if defined S_ISLNK && defined S_IFREG
-extern char c3[S_ISLNK (S_IFREG) ? -1 : 1];
-#endif
 
-#if defined S_ISSOCK && defined S_IFREG
-extern char c4[S_ISSOCK (S_IFREG) ? -1 : 1];
-#endif
+  GL_M4_GNULIB_ILOGBL=0
 
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  ac_cv_header_stat_broken=no
-else $as_nop
-  ac_cv_header_stat_broken=yes
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_stat_broken" >&5
-printf "%s\n" "$ac_cv_header_stat_broken" >&6; }
-if test $ac_cv_header_stat_broken = yes; then
 
-printf "%s\n" "#define STAT_MACROS_BROKEN 1" >>confdefs.h
 
-fi
+  GL_M4_GNULIB_ISFINITE=0
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for C/C++ restrict keyword" >&5
-printf %s "checking for C/C++ restrict keyword... " >&6; }
-if test ${ac_cv_c_restrict+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  ac_cv_c_restrict=no
-   # Put '__restrict__' first, to avoid problems with glibc and non-GCC; see:
-   # https://lists.gnu.org/archive/html/bug-autoconf/2016-02/msg00006.html
-   # Put 'restrict' last, because C++ lacks it.
-   for ac_kw in __restrict__ __restrict _Restrict restrict; do
-     cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-typedef int *int_ptr;
-	   int foo (int_ptr $ac_kw ip) { return ip[0]; }
-	   int bar (int [$ac_kw]); /* Catch GCC bug 14050.  */
-	   int bar (int ip[$ac_kw]) { return ip[0]; }
 
-int
-main (void)
-{
-int s[1];
-	   int *$ac_kw t = s;
-	   t[0] = 0;
-	   return foo (t) + bar (t);
 
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  ac_cv_c_restrict=$ac_kw
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-     test "$ac_cv_c_restrict" != no && break
-   done
+  GL_M4_GNULIB_ISINF=0
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_restrict" >&5
-printf "%s\n" "$ac_cv_c_restrict" >&6; }
 
- case $ac_cv_c_restrict in
-   restrict) ;;
-   no) printf "%s\n" "#define restrict /**/" >>confdefs.h
- ;;
-   *)  printf "%s\n" "#define restrict $ac_cv_c_restrict" >>confdefs.h
- ;;
- esac
 
+  GL_M4_GNULIB_ISNAN=0
 
 
 
+  GL_M4_GNULIB_ISNANF=0
 
 
 
+  GL_M4_GNULIB_ISNAND=0
 
 
 
+  GL_M4_GNULIB_ISNANL=0
 
 
 
+  GL_M4_GNULIB_LDEXPF=0
 
 
-     if test $gl_cv_have_include_next = yes; then
-       gl_cv_next_sys_stat_h='<'sys/stat.h'>'
-     else
-       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking absolute name of <sys/stat.h>" >&5
-printf %s "checking absolute name of <sys/stat.h>... " >&6; }
-if test ${gl_cv_next_sys_stat_h+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-             if test $ac_cv_header_sys_stat_h = yes; then
+  GL_M4_GNULIB_LDEXPL=0
 
 
 
+  GL_M4_GNULIB_LOG=0
 
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sys/stat.h>
-_ACEOF
-                case "$host_os" in
-    aix*) gl_absname_cpp="$ac_cpp -C" ;;
-    *)    gl_absname_cpp="$ac_cpp" ;;
-  esac
 
-  case "$host_os" in
-    mingw*)
-                                          gl_dirsep_regex='[/\\]'
-      ;;
-    *)
-      gl_dirsep_regex='\/'
-      ;;
-  esac
-      gl_make_literal_regex_sed='s,[]$^\\.*/[],\\&,g'
-  gl_header_literal_regex=`echo 'sys/stat.h' \
-                           | sed -e "$gl_make_literal_regex_sed"`
-  gl_absolute_header_sed="/${gl_dirsep_regex}${gl_header_literal_regex}/"'{
-      s/.*"\(.*'"${gl_dirsep_regex}${gl_header_literal_regex}"'\)".*/\1/
-      s|^/[^/]|//&|
-      p
-      q
-    }'
 
-        gl_cv_absolute_sys_stat_h=`(eval "$gl_absname_cpp conftest.$ac_ext") 2>&5 |
-  sed -n "$gl_absolute_header_sed"`
+  GL_M4_GNULIB_LOGF=0
 
-           gl_header=$gl_cv_absolute_sys_stat_h
-           gl_cv_next_sys_stat_h='"'$gl_header'"'
-          else
-               gl_cv_next_sys_stat_h='<'sys/stat.h'>'
-             fi
 
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_next_sys_stat_h" >&5
-printf "%s\n" "$gl_cv_next_sys_stat_h" >&6; }
-     fi
-     NEXT_SYS_STAT_H=$gl_cv_next_sys_stat_h
+  GL_M4_GNULIB_LOGL=0
 
-     if test $gl_cv_have_include_next = yes || test $gl_cv_have_include_next = buggy; then
-       # INCLUDE_NEXT_AS_FIRST_DIRECTIVE='include_next'
-       gl_next_as_first_directive='<'sys/stat.h'>'
-     else
-       # INCLUDE_NEXT_AS_FIRST_DIRECTIVE='include'
-       gl_next_as_first_directive=$gl_cv_next_sys_stat_h
-     fi
-     NEXT_AS_FIRST_DIRECTIVE_SYS_STAT_H=$gl_next_as_first_directive
 
 
+  GL_M4_GNULIB_LOG10=0
 
 
 
+  GL_M4_GNULIB_LOG10F=0
 
 
 
-    WINDOWS_STAT_TIMESPEC=0
+  GL_M4_GNULIB_LOG10L=0
 
 
 
+  GL_M4_GNULIB_LOG1P=0
 
 
 
+  GL_M4_GNULIB_LOG1PF=0
 
 
-      ac_fn_c_check_type "$LINENO" "nlink_t" "ac_cv_type_nlink_t" "#include <sys/types.h>
-     #include <sys/stat.h>
-"
-if test "x$ac_cv_type_nlink_t" = xyes
-then :
 
-else $as_nop
+  GL_M4_GNULIB_LOG1PL=0
 
-printf "%s\n" "#define nlink_t int" >>confdefs.h
 
-fi
 
+  GL_M4_GNULIB_LOG2=0
 
 
 
+  GL_M4_GNULIB_LOG2F=0
 
 
 
+  GL_M4_GNULIB_LOG2L=0
+
+
+
+  GL_M4_GNULIB_LOGB=0
+
+
+
+  GL_M4_GNULIB_LOGBF=0
+
+
+
+  GL_M4_GNULIB_LOGBL=0
+
+
+
+  GL_M4_GNULIB_MODF=0
+
+
+
+  GL_M4_GNULIB_MODFF=0
 
-  case "$host_os" in
-    mingw*)
-      ac_fn_c_check_header_compile "$LINENO" "sdkddkver.h" "ac_cv_header_sdkddkver_h" "$ac_includes_default"
-if test "x$ac_cv_header_sdkddkver_h" = xyes
-then :
-  printf "%s\n" "#define HAVE_SDKDDKVER_H 1" >>confdefs.h
 
-fi
 
-      ;;
-  esac
+  GL_M4_GNULIB_MODFL=0
 
 
 
+  GL_M4_GNULIB_POWF=0
 
 
 
+  GL_M4_GNULIB_REMAINDER=0
 
-  GL_M4_GNULIB_FCHMODAT=0
 
 
+  GL_M4_GNULIB_REMAINDERF=0
 
-  GL_M4_GNULIB_FSTAT=0
 
 
+  GL_M4_GNULIB_REMAINDERL=0
 
-  GL_M4_GNULIB_FSTATAT=0
 
 
+  GL_M4_GNULIB_RINT=0
 
-  GL_M4_GNULIB_FUTIMENS=0
 
 
+  GL_M4_GNULIB_RINTF=0
 
-  GL_M4_GNULIB_GETUMASK=0
 
 
+  GL_M4_GNULIB_RINTL=0
 
-  GL_M4_GNULIB_LCHMOD=0
 
 
+  GL_M4_GNULIB_ROUND=0
 
-  GL_M4_GNULIB_LSTAT=0
 
 
+  GL_M4_GNULIB_ROUNDF=0
 
-  GL_M4_GNULIB_MKDIR=0
 
 
+  GL_M4_GNULIB_ROUNDL=0
 
-  GL_M4_GNULIB_MKDIRAT=0
 
 
+  GL_M4_GNULIB_SIGNBIT=0
 
-  GL_M4_GNULIB_MKFIFO=0
 
 
+  GL_M4_GNULIB_SINF=0
 
-  GL_M4_GNULIB_MKFIFOAT=0
 
 
+  GL_M4_GNULIB_SINL=0
 
-  GL_M4_GNULIB_MKNOD=0
 
 
+  GL_M4_GNULIB_SINHF=0
 
-  GL_M4_GNULIB_MKNODAT=0
 
 
+  GL_M4_GNULIB_SQRTF=0
 
-  GL_M4_GNULIB_STAT=0
 
 
+  GL_M4_GNULIB_SQRTL=0
 
-  GL_M4_GNULIB_UTIMENSAT=0
 
 
+  GL_M4_GNULIB_TANF=0
 
-  GL_M4_GNULIB_OVERRIDES_STRUCT_STAT=0
 
 
+  GL_M4_GNULIB_TANL=0
 
-  GL_M4_GNULIB_MDA_CHMOD=1
 
 
+  GL_M4_GNULIB_TANHF=0
 
-  GL_M4_GNULIB_MDA_MKDIR=1
 
 
+  GL_M4_GNULIB_TRUNC=0
 
-  GL_M4_GNULIB_MDA_UMASK=1
 
 
+  GL_M4_GNULIB_TRUNCF=0
 
 
-ac_fn_check_decl "$LINENO" "ftello" "ac_cv_have_decl_ftello" "$ac_includes_default" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_ftello" = xyes
-then :
-  ac_have_decl=1
-else $as_nop
-  ac_have_decl=0
-fi
-printf "%s\n" "#define HAVE_DECL_FTELLO $ac_have_decl" >>confdefs.h
 
+  GL_M4_GNULIB_TRUNCL=0
 
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ungetc works on arbitrary bytes" >&5
-printf %s "checking whether ungetc works on arbitrary bytes... " >&6; }
-if test ${gl_cv_func_ungetc_works+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  if test "$cross_compiling" = yes
-then :
-  case "$host_os" in
-                          # Guess yes on glibc systems.
-           *-gnu* | gnu*) gl_cv_func_ungetc_works="guessing yes" ;;
-                          # Guess yes on musl systems.
-           *-musl*)       gl_cv_func_ungetc_works="guessing yes" ;;
-                          # Guess yes on bionic systems.
-           *-android*)    gl_cv_func_ungetc_works="guessing yes" ;;
-                          # Guess yes on native Windows.
-           mingw*)        gl_cv_func_ungetc_works="guessing yes" ;;
-                          # If we don't know, obey --enable-cross-guesses.
-           *)             gl_cv_func_ungetc_works="$gl_cross_guess_normal" ;;
-         esac
+  GL_M4_GNULIB_MDA_J0=1
 
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
 
-#include <stdio.h>
 
-int
-main (void)
-{
-FILE *f;
-            if (!(f = fopen ("conftest.tmp", "w+")))
-              return 1;
-            if (fputs ("abc", f) < 0)
-              { fclose (f); return 2; }
-            rewind (f);
-            if (fgetc (f) != 'a')
-              { fclose (f); return 3; }
-            if (fgetc (f) != 'b')
-              { fclose (f); return 4; }
-            if (ungetc ('d', f) != 'd')
-              { fclose (f); return 5; }
-            if (ftell (f) != 1)
-              { fclose (f); return 6; }
-            if (fgetc (f) != 'd')
-              { fclose (f); return 7; }
-            if (ftell (f) != 2)
-              { fclose (f); return 8; }
-            if (fseek (f, 0, SEEK_CUR) != 0)
-              { fclose (f); return 9; }
-            if (ftell (f) != 2)
-              { fclose (f); return 10; }
-            if (fgetc (f) != 'c')
-              { fclose (f); return 11; }
-            fclose (f);
-            remove ("conftest.tmp");
+  GL_M4_GNULIB_MDA_J1=1
 
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
-then :
-  gl_cv_func_ungetc_works=yes
-else $as_nop
-  gl_cv_func_ungetc_works=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
 
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ungetc_works" >&5
-printf "%s\n" "$gl_cv_func_ungetc_works" >&6; }
-  gl_ftello_broken_after_ungetc=no
-  case "$gl_cv_func_ungetc_works" in
-    *yes) ;;
-    *)
-                  case "$host_os" in
-        darwin*) gl_ftello_broken_after_ungetc=yes ;;
-        *)
+  GL_M4_GNULIB_MDA_JN=1
 
-printf "%s\n" "#define FUNC_UNGETC_BROKEN 1" >>confdefs.h
 
-          ;;
-      esac
-      ;;
-  esac
 
+  GL_M4_GNULIB_MDA_Y0=1
 
 
 
+  GL_M4_GNULIB_MDA_Y1=1
 
 
 
+  GL_M4_GNULIB_MDA_YN=1
 
 
 
-  if test $ac_cv_have_decl_ftello = no; then
-    HAVE_DECL_FTELLO=0
-  fi
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for ftello" >&5
-printf %s "checking for ftello... " >&6; }
-if test ${gl_cv_func_ftello+y}
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether long double and double are the same" >&5
+printf %s "checking whether long double and double are the same... " >&6; }
+if test ${gl_cv_long_double_equals_double+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-
-      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <stdio.h>
+#include <float.h>
 int
 main (void)
 {
-ftello (stdin);
+typedef int check[sizeof (long double) == sizeof (double)
+                              && LDBL_MANT_DIG == DBL_MANT_DIG
+                              && LDBL_MAX_EXP == DBL_MAX_EXP
+                              && LDBL_MIN_EXP == DBL_MIN_EXP
+                              ? 1 : -1];
+
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"
+if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_func_ftello=yes
+  gl_cv_long_double_equals_double=yes
 else $as_nop
-  gl_cv_func_ftello=no
+  gl_cv_long_double_equals_double=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ftello" >&5
-printf "%s\n" "$gl_cv_func_ftello" >&6; }
-  if test $gl_cv_func_ftello = no; then
-    HAVE_FTELLO=0
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_long_double_equals_double" >&5
+printf "%s\n" "$gl_cv_long_double_equals_double" >&6; }
+  if test $gl_cv_long_double_equals_double = yes; then
+
+printf "%s\n" "#define HAVE_SAME_LONG_DOUBLE_AS_DOUBLE 1" >>confdefs.h
+
+    HAVE_SAME_LONG_DOUBLE_AS_DOUBLE=1
   else
-    if test $WINDOWS_64_BIT_OFF_T = 1; then
-      REPLACE_FTELLO=1
-    fi
-    if test $gl_cv_var_stdin_large_offset = no; then
-      REPLACE_FTELLO=1
-    fi
-    if test $REPLACE_FTELLO = 0; then
+    HAVE_SAME_LONG_DOUBLE_AS_DOUBLE=0
+  fi
 
-      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ftello works" >&5
-printf %s "checking whether ftello works... " >&6; }
-if test ${gl_cv_func_ftello_works+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-                              case "$host_os" in
-                      # Guess no on Solaris.
-            solaris*) gl_cv_func_ftello_works="guessing no" ;;
-                      # Guess yes on native Windows.
-            mingw*)   gl_cv_func_ftello_works="guessing yes" ;;
-                      # Guess yes otherwise.
-            *)        gl_cv_func_ftello_works="guessing yes" ;;
-          esac
-          if test "$cross_compiling" = yes
+
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether stdin defaults to large file offsets" >&5
+printf %s "checking whether stdin defaults to large file offsets... " >&6; }
+if test ${gl_cv_var_stdin_large_offset+y}
 then :
-  :
+  printf %s "(cached) " >&6
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-
 #include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#define TESTFILE "conftest.tmp"
 int
 main (void)
 {
-  FILE *fp;
-
-  /* Create a file with some contents.  */
-  fp = fopen (TESTFILE, "w");
-  if (fp == NULL)
-    return 70;
-  if (fwrite ("foogarsh", 1, 8, fp) < 8)
-    { fclose (fp); return 71; }
-  if (fclose (fp))
-    return 72;
-
-  /* The file's contents is now "foogarsh".  */
-
-  /* Try writing after reading to EOF.  */
-  fp = fopen (TESTFILE, "r+");
-  if (fp == NULL)
-    return 73;
-  if (fseek (fp, -1, SEEK_END))
-    { fclose (fp); return 74; }
-  if (!(getc (fp) == 'h'))
-    { fclose (fp); return 1; }
-  if (!(getc (fp) == EOF))
-    { fclose (fp); return 2; }
-  if (!(ftell (fp) == 8))
-    { fclose (fp); return 3; }
-  if (!(ftell (fp) == 8))
-    { fclose (fp); return 4; }
-  if (!(putc ('!', fp) == '!'))
-    { fclose (fp); return 5; }
-  if (!(ftell (fp) == 9))
-    { fclose (fp); return 6; }
-  if (!(fclose (fp) == 0))
-    return 7;
-  fp = fopen (TESTFILE, "r");
-  if (fp == NULL)
-    return 75;
-  {
-    char buf[10];
-    if (!(fread (buf, 1, 10, fp) == 9))
-      { fclose (fp); return 10; }
-    if (!(memcmp (buf, "foogarsh!", 9) == 0))
-      { fclose (fp); return 11; }
-  }
-  if (!(fclose (fp) == 0))
-    return 12;
-
-  /* The file's contents is now "foogarsh!".  */
-
+#if defined __SL64 && defined __SCLE /* cygwin */
+  /* Cygwin 1.5.24 and earlier fail to put stdin in 64-bit mode, making
+     fseeko/ftello needlessly fail.  This bug was fixed in 1.5.25, and
+     it is easier to do a version check than building a runtime test.  */
+# include <cygwin/version.h>
+# if CYGWIN_VERSION_DLL_COMBINED < CYGWIN_VERSION_DLL_MAKE_COMBINED (1005, 25)
+  choke me
+# endif
+#endif
+  ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"
+if ac_fn_c_try_link "$LINENO"
 then :
-  gl_cv_func_ftello_works=yes
+  gl_cv_var_stdin_large_offset=yes
 else $as_nop
-  gl_cv_func_ftello_works=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
+  gl_cv_var_stdin_large_offset=no
 fi
-
-
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ftello_works" >&5
-printf "%s\n" "$gl_cv_func_ftello_works" >&6; }
-      case "$gl_cv_func_ftello_works" in
-        *yes) ;;
-        *)
-          REPLACE_FTELLO=1
-
-printf "%s\n" "#define FTELLO_BROKEN_AFTER_SWITCHING_FROM_READ_TO_WRITE 1" >>confdefs.h
-
-          ;;
-      esac
-    fi
-    if test $REPLACE_FTELLO = 0; then
-
-      if test $gl_ftello_broken_after_ungetc = yes; then
-        REPLACE_FTELLO=1
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_var_stdin_large_offset" >&5
+printf "%s\n" "$gl_cv_var_stdin_large_offset" >&6; }
 
-printf "%s\n" "#define FTELLO_BROKEN_AFTER_UNGETC 1" >>confdefs.h
 
-      fi
-    fi
-  fi
 
 
 
-   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether getcwd (NULL, 0) allocates memory for result" >&5
-printf %s "checking whether getcwd (NULL, 0) allocates memory for result... " >&6; }
-if test ${gl_cv_func_getcwd_null+y}
+  case "$host_os" in
+    mingw*)
+                        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for 64-bit off_t" >&5
+printf %s "checking for 64-bit off_t... " >&6; }
+if test ${gl_cv_type_off_t_64+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  if test "$cross_compiling" = yes
-then :
-  case "$host_os" in
-                           # Guess yes on glibc systems.
-            *-gnu* | gnu*) gl_cv_func_getcwd_null="guessing yes";;
-                           # Guess yes on musl systems.
-            *-musl*)       gl_cv_func_getcwd_null="guessing yes";;
-                           # Guess yes on Cygwin.
-            cygwin*)       gl_cv_func_getcwd_null="guessing yes";;
-                           # If we don't know, obey --enable-cross-guesses.
-            *)             gl_cv_func_getcwd_null="$gl_cross_guess_normal";;
-          esac
-
-else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-
-#	 include <stdlib.h>
-#        if HAVE_UNISTD_H
-#         include <unistd.h>
-#        else /* on Windows with MSVC */
-#         include <direct.h>
-#        endif
-
-
-$gl_mda_defines
-
-#        ifndef getcwd
-         char *getcwd ();
-#        endif
+#include <sys/types.h>
+                int verify_off_t_size[sizeof (off_t) >= 8 ? 1 : -1];
 
 int
 main (void)
 {
 
-#if defined _WIN32 && ! defined __CYGWIN__
-/* mingw cwd does not start with '/', but _getcwd does allocate.
-   However, mingw fails to honor non-zero size.  */
-#else
-           if (chdir ("/") != 0)
-             return 1;
-           else
-             {
-               char *f = getcwd (NULL, 0);
-               if (! f)
-                 return 2;
-               if (f[0] != '/')
-                 { free (f); return 3; }
-               if (f[1] != '\0')
-                 { free (f); return 4; }
-               free (f);
-               return 0;
-             }
-#endif
-
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"
+if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_func_getcwd_null=yes
+  gl_cv_type_off_t_64=yes
 else $as_nop
-  gl_cv_func_getcwd_null=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
+  gl_cv_type_off_t_64=no
 fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_getcwd_null" >&5
-printf "%s\n" "$gl_cv_func_getcwd_null" >&6; }
-
-
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for getcwd with POSIX signature" >&5
-printf %s "checking for getcwd with POSIX signature... " >&6; }
-if test ${gl_cv_func_getcwd_posix_signature+y}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_type_off_t_64" >&5
+printf "%s\n" "$gl_cv_type_off_t_64" >&6; }
+      if test $gl_cv_type_off_t_64 = no; then
+        WINDOWS_64_BIT_OFF_T=1
+      else
+        WINDOWS_64_BIT_OFF_T=0
+      fi
+                        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for 64-bit st_size" >&5
+printf %s "checking for 64-bit st_size... " >&6; }
+if test ${gl_cv_member_st_size_64+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <unistd.h>
-
-
-$gl_mda_defines
+#include <sys/types.h>
+                struct stat buf;
+                int verify_st_size_size[sizeof (buf.st_size) >= 8 ? 1 : -1];
 
 int
 main (void)
 {
-extern
-           #ifdef __cplusplus
-           "C"
-           #endif
-           char *getcwd (char *, size_t);
 
   ;
   return 0;
 }
-
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_func_getcwd_posix_signature=yes
+  gl_cv_member_st_size_64=yes
 else $as_nop
-  gl_cv_func_getcwd_posix_signature=no
+  gl_cv_member_st_size_64=no
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_getcwd_posix_signature" >&5
-printf "%s\n" "$gl_cv_func_getcwd_posix_signature" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_member_st_size_64" >&5
+printf "%s\n" "$gl_cv_member_st_size_64" >&6; }
+      if test $gl_cv_member_st_size_64 = no; then
+        WINDOWS_64_BIT_ST_SIZE=1
+      else
+        WINDOWS_64_BIT_ST_SIZE=0
+      fi
+      ;;
+    *)
+                                                      WINDOWS_64_BIT_OFF_T=0
+      WINDOWS_64_BIT_ST_SIZE=0
+      ;;
+  esac
+
+
+
 
-ac_fn_check_decl "$LINENO" "getcwd" "ac_cv_have_decl_getcwd" "$ac_includes_default" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_getcwd" = xyes
-then :
-  ac_have_decl=1
-else $as_nop
-  ac_have_decl=0
-fi
-printf "%s\n" "#define HAVE_DECL_GETCWD $ac_have_decl" >>confdefs.h
 
 
-ac_fn_check_decl "$LINENO" "getdtablesize" "ac_cv_have_decl_getdtablesize" "$ac_includes_default" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_getdtablesize" = xyes
-then :
-  ac_have_decl=1
-else $as_nop
-  ac_have_decl=0
-fi
-printf "%s\n" "#define HAVE_DECL_GETDTABLESIZE $ac_have_decl" >>confdefs.h
 
 
 
 
 
+printf "%s\n" "#define _USE_STD_STAT 1" >>confdefs.h
 
 
 
@@ -15099,23 +15374,20 @@
 
 
      if test $gl_cv_have_include_next = yes; then
-       gl_cv_next_getopt_h='<'getopt.h'>'
+       gl_cv_next_sys_types_h='<'sys/types.h'>'
      else
-       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking absolute name of <getopt.h>" >&5
-printf %s "checking absolute name of <getopt.h>... " >&6; }
-if test ${gl_cv_next_getopt_h+y}
+       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking absolute name of <sys/types.h>" >&5
+printf %s "checking absolute name of <sys/types.h>... " >&6; }
+if test ${gl_cv_next_sys_types_h+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
 
-             if test $ac_cv_header_getopt_h = yes; then
-
-
 
 
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <getopt.h>
+#include <sys/types.h>
 _ACEOF
                 case "$host_os" in
     aix*) gl_absname_cpp="$ac_cpp -C" ;;
@@ -15131,7 +15403,7 @@
       ;;
   esac
       gl_make_literal_regex_sed='s,[]$^\\.*/[],\\&,g'
-  gl_header_literal_regex=`echo 'getopt.h' \
+  gl_header_literal_regex=`echo 'sys/types.h' \
                            | sed -e "$gl_make_literal_regex_sed"`
   gl_absolute_header_sed="/${gl_dirsep_regex}${gl_header_literal_regex}/"'{
       s/.*"\(.*'"${gl_dirsep_regex}${gl_header_literal_regex}"'\)".*/\1/
@@ -15140,576 +15412,423 @@
       q
     }'
 
-        gl_cv_absolute_getopt_h=`(eval "$gl_absname_cpp conftest.$ac_ext") 2>&5 |
+        gl_cv_absolute_sys_types_h=`(eval "$gl_absname_cpp conftest.$ac_ext") 2>&5 |
   sed -n "$gl_absolute_header_sed"`
 
-           gl_header=$gl_cv_absolute_getopt_h
-           gl_cv_next_getopt_h='"'$gl_header'"'
-          else
-               gl_cv_next_getopt_h='<'getopt.h'>'
-             fi
+           gl_header=$gl_cv_absolute_sys_types_h
+           gl_cv_next_sys_types_h='"'$gl_header'"'
 
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_next_getopt_h" >&5
-printf "%s\n" "$gl_cv_next_getopt_h" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_next_sys_types_h" >&5
+printf "%s\n" "$gl_cv_next_sys_types_h" >&6; }
      fi
-     NEXT_GETOPT_H=$gl_cv_next_getopt_h
+     NEXT_SYS_TYPES_H=$gl_cv_next_sys_types_h
 
      if test $gl_cv_have_include_next = yes || test $gl_cv_have_include_next = buggy; then
        # INCLUDE_NEXT_AS_FIRST_DIRECTIVE='include_next'
-       gl_next_as_first_directive='<'getopt.h'>'
+       gl_next_as_first_directive='<'sys/types.h'>'
      else
        # INCLUDE_NEXT_AS_FIRST_DIRECTIVE='include'
-       gl_next_as_first_directive=$gl_cv_next_getopt_h
+       gl_next_as_first_directive=$gl_cv_next_sys_types_h
      fi
-     NEXT_AS_FIRST_DIRECTIVE_GETOPT_H=$gl_next_as_first_directive
+     NEXT_AS_FIRST_DIRECTIVE_SYS_TYPES_H=$gl_next_as_first_directive
+
+
 
 
 
 
-  if test $ac_cv_header_getopt_h = yes; then
-    HAVE_GETOPT_H=1
-  else
-    HAVE_GETOPT_H=0
-  fi
 
 
-  gl_replace_getopt=
 
-    if test -z "$gl_replace_getopt" && test $gl_getopt_required = GNU; then
-           for ac_header in getopt.h
-do :
-  ac_fn_c_check_header_compile "$LINENO" "getopt.h" "ac_cv_header_getopt_h" "$ac_includes_default"
-if test "x$ac_cv_header_getopt_h" = xyes
-then :
-  printf "%s\n" "#define HAVE_GETOPT_H 1" >>confdefs.h
 
+
+
+    WINDOWS_STAT_INODES=0
+
+
+
+ac_fn_check_decl "$LINENO" "fseeko" "ac_cv_have_decl_fseeko" "$ac_includes_default" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_fseeko" = xyes
+then :
+  ac_have_decl=1
 else $as_nop
-  gl_replace_getopt=yes
+  ac_have_decl=0
 fi
+printf "%s\n" "#define HAVE_DECL_FSEEKO $ac_have_decl" >>confdefs.h
+
+
+
 
-done
-  fi
 
-    if test -z "$gl_replace_getopt" && test $gl_getopt_required = GNU; then
 
-  for ac_func in getopt_long_only
-do :
-  ac_fn_c_check_func "$LINENO" "getopt_long_only" "ac_cv_func_getopt_long_only"
-if test "x$ac_cv_func_getopt_long_only" = xyes
-then :
-  printf "%s\n" "#define HAVE_GETOPT_LONG_ONLY 1" >>confdefs.h
 
-else $as_nop
-  gl_replace_getopt=yes
-fi
 
-done
-  fi
 
-          if test -z "$gl_replace_getopt"; then
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether getopt is POSIX compatible" >&5
-printf %s "checking whether getopt is POSIX compatible... " >&6; }
-if test ${gl_cv_func_getopt_posix+y}
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for fseeko" >&5
+printf %s "checking for fseeko... " >&6; }
+if test ${gl_cv_func_fseeko+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
 
-                                                if test $cross_compiling = no; then
-                              if test "$cross_compiling" = yes
-then :
-  { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
-as_fn_error $? "cannot run test program while cross compiling
-See \`config.log' for more details" "$LINENO" 5; }
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-
-#include <unistd.h>
-#include <stdlib.h>
-#include <string.h>
+#include <stdio.h>
 
 int
-main ()
+main (void)
 {
-  static char program[] = "program";
-  static char a[] = "-a";
-  static char foo[] = "foo";
-  static char bar[] = "bar";
-  char *argv[] = { program, a, foo, bar, NULL };
-  int c;
-
-  c = getopt (4, argv, "ab");
-  if (!(c == 'a'))
-    return 1;
-  c = getopt (4, argv, "ab");
-  if (!(c == -1))
-    return 2;
-  if (!(optind == 2))
-    return 3;
+fseeko (stdin, 0, 0);
+  ;
   return 0;
 }
-
 _ACEOF
-if ac_fn_c_try_run "$LINENO"
+if ac_fn_c_try_link "$LINENO"
 then :
-  gl_cv_func_getopt_posix=maybe
+  gl_cv_func_fseeko=yes
 else $as_nop
-  gl_cv_func_getopt_posix=no
+  gl_cv_func_fseeko=no
 fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+
 fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_fseeko" >&5
+printf "%s\n" "$gl_cv_func_fseeko" >&6; }
 
-          if test $gl_cv_func_getopt_posix = maybe; then
-                                    if test "$cross_compiling" = yes
-then :
-  { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
-as_fn_error $? "cannot run test program while cross compiling
-See \`config.log' for more details" "$LINENO" 5; }
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
 
-#include <unistd.h>
-#include <stdlib.h>
-#include <string.h>
+  if test $ac_cv_have_decl_fseeko = no; then
+    HAVE_DECL_FSEEKO=0
+  fi
 
-int
-main ()
-{
-  static char program[] = "program";
-  static char donald[] = "donald";
-  static char p[] = "-p";
-  static char billy[] = "billy";
-  static char duck[] = "duck";
-  static char a[] = "-a";
-  static char bar[] = "bar";
-  char *argv[] = { program, donald, p, billy, duck, a, bar, NULL };
-  int c;
+  if test $gl_cv_func_fseeko = no; then
+    HAVE_FSEEKO=0
+  else
+    if test $WINDOWS_64_BIT_OFF_T = 1; then
+      REPLACE_FSEEKO=1
+    fi
+    if test $gl_cv_var_stdin_large_offset = no; then
+      REPLACE_FSEEKO=1
+    fi
 
-  c = getopt (7, argv, "+abp:q:");
-  if (!(c == -1))
-    return 4;
-  if (!(strcmp (argv[0], "program") == 0))
-    return 5;
-  if (!(strcmp (argv[1], "donald") == 0))
-    return 6;
-  if (!(strcmp (argv[2], "-p") == 0))
-    return 7;
-  if (!(strcmp (argv[3], "billy") == 0))
-    return 8;
-  if (!(strcmp (argv[4], "duck") == 0))
-    return 9;
-  if (!(strcmp (argv[5], "-a") == 0))
-    return 10;
-  if (!(strcmp (argv[6], "bar") == 0))
-    return 11;
-  if (!(optind == 1))
-    return 12;
-  return 0;
-}
 
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether fflush works on input streams" >&5
+printf %s "checking whether fflush works on input streams... " >&6; }
+if test ${gl_cv_func_fflush_stdin+y}
 then :
-  gl_cv_func_getopt_posix=maybe
+  printf %s "(cached) " >&6
 else $as_nop
-  gl_cv_func_getopt_posix=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-
-          fi
-          if test $gl_cv_func_getopt_posix = maybe; then
-                        if test "$cross_compiling" = yes
+  echo hello world > conftest.txt
+     if test "$cross_compiling" = yes
 then :
-  { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
-as_fn_error $? "cannot run test program while cross compiling
-See \`config.log' for more details" "$LINENO" 5; }
+  case "$host_os" in
+                  # Guess no on native Windows.
+          mingw*) gl_cv_func_fflush_stdin="guessing no" ;;
+          *)      gl_cv_func_fflush_stdin=cross ;;
+        esac
+
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
-#include <unistd.h>
-#include <stdlib.h>
-#include <string.h>
+#include <stdio.h>
+#if HAVE_UNISTD_H
+# include <unistd.h>
+#else /* on Windows with MSVC */
+# include <io.h>
+#endif
+
+
+$gl_mda_defines
 
 int
-main ()
+main (void)
 {
-  static char program[] = "program";
-  static char ab[] = "-ab";
-  char *argv[3] = { program, ab, NULL };
-  if (getopt (2, argv, "ab:") != 'a')
-    return 13;
-  if (getopt (2, argv, "ab:") != '?')
-    return 14;
-  if (optopt != 'b')
-    return 15;
-  if (optind != 2)
-    return 16;
+FILE *f = fopen ("conftest.txt", "r");
+         char buffer[10];
+         int fd;
+         int c;
+         if (f == NULL)
+           return 1;
+         fd = fileno (f);
+         if (fd < 0 || fread (buffer, 1, 5, f) != 5)
+           { fclose (f); return 2; }
+         /* For deterministic results, ensure f read a bigger buffer.  */
+         if (lseek (fd, 0, SEEK_CUR) == 5)
+           { fclose (f); return 3; }
+         /* POSIX requires fflush-fseek to set file offset of fd.  This fails
+            on BSD systems and on mingw.  */
+         if (fflush (f) != 0 || fseek (f, 0, SEEK_CUR) != 0)
+           { fclose (f); return 4; }
+         if (lseek (fd, 0, SEEK_CUR) != 5)
+           { fclose (f); return 5; }
+         /* Verify behaviour of fflush after ungetc. See
+            <https://www.opengroup.org/austin/aardvark/latest/xshbug3.txt>  */
+         /* Verify behaviour of fflush after a backup ungetc.  This fails on
+            mingw.  */
+         c = fgetc (f);
+         ungetc (c, f);
+         fflush (f);
+         if (fgetc (f) != c)
+           { fclose (f); return 6; }
+         /* Verify behaviour of fflush after a non-backup ungetc.  This fails
+            on glibc 2.8 and on BSD systems.  */
+         c = fgetc (f);
+         ungetc ('@', f);
+         fflush (f);
+         if (fgetc (f) != c)
+           { fclose (f); return 7; }
+         fclose (f);
+         return 0;
+
+  ;
   return 0;
 }
-
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_func_getopt_posix=yes
+  gl_cv_func_fflush_stdin=yes
 else $as_nop
-  gl_cv_func_getopt_posix=no
+  gl_cv_func_fflush_stdin=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
-          fi
-        else
-          case "$host_os" in
-            darwin* | aix* | mingw*) gl_cv_func_getopt_posix="guessing no";;
-            *)                       gl_cv_func_getopt_posix="guessing yes";;
-          esac
-        fi
+     rm conftest.txt
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_getopt_posix" >&5
-printf "%s\n" "$gl_cv_func_getopt_posix" >&6; }
-    case "$gl_cv_func_getopt_posix" in
-      *no) gl_replace_getopt=yes ;;
-    esac
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_fflush_stdin" >&5
+printf "%s\n" "$gl_cv_func_fflush_stdin" >&6; }
+  case "$gl_cv_func_fflush_stdin" in
+    *yes) gl_func_fflush_stdin=1 ;;
+    *no)  gl_func_fflush_stdin=0 ;;
+    *)    gl_func_fflush_stdin='(-1)' ;;
+  esac
+
+printf "%s\n" "#define FUNC_FFLUSH_STDIN $gl_func_fflush_stdin" >>confdefs.h
+
+
+      case "$gl_cv_func_fflush_stdin" in
+        *yes) ;;
+        *) REPLACE_FSEEKO=1 ;;
+      esac
+
   fi
 
-  if test -z "$gl_replace_getopt" && test $gl_getopt_required = GNU; then
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working GNU getopt function" >&5
-printf %s "checking for working GNU getopt function... " >&6; }
-if test ${gl_cv_func_getopt_gnu+y}
+
+    HAVE_FCHMODAT=1;
+  HAVE_FSTATAT=1;
+  HAVE_FUTIMENS=1;
+  HAVE_GETUMASK=1;
+  HAVE_LCHMOD=1;
+  HAVE_LSTAT=1;
+  HAVE_MKDIRAT=1;
+  HAVE_MKFIFO=1;
+  HAVE_MKFIFOAT=1;
+  HAVE_MKNOD=1;
+  HAVE_MKNODAT=1;
+  HAVE_UTIMENSAT=1;
+  REPLACE_FCHMODAT=0;
+  REPLACE_FSTAT=0;
+  REPLACE_FSTATAT=0;
+  REPLACE_FUTIMENS=0;
+  REPLACE_LSTAT=0;
+  REPLACE_MKDIR=0;
+  REPLACE_MKFIFO=0;
+  REPLACE_MKFIFOAT=0;
+  REPLACE_MKNOD=0;
+  REPLACE_MKNODAT=0;
+  REPLACE_STAT=0;
+  REPLACE_UTIMENSAT=0;
+
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether stat file-mode macros are broken" >&5
+printf %s "checking whether stat file-mode macros are broken... " >&6; }
+if test ${ac_cv_header_stat_broken+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  # Even with POSIXLY_CORRECT, the GNU extension of leading '-' in the
-       # optstring is necessary for programs like m4 that have POSIX-mandated
-       # semantics for supporting options interspersed with files.
-       # Also, since getopt_long is a GNU extension, we require optind=0.
-       # Bash ties 'set -o posix' to a non-exported POSIXLY_CORRECT;
-       # so take care to revert to the correct (non-)export state.
-       gl_awk_probe='BEGIN { if ("POSIXLY_CORRECT" in ENVIRON) print "x" }'
-       case ${POSIXLY_CORRECT+x}`$AWK "$gl_awk_probe" </dev/null` in
-         xx) gl_had_POSIXLY_CORRECT=exported ;;
-         x)  gl_had_POSIXLY_CORRECT=yes      ;;
-         *)  gl_had_POSIXLY_CORRECT=         ;;
-       esac
-       POSIXLY_CORRECT=1
-       export POSIXLY_CORRECT
-       if test "$cross_compiling" = yes
-then :
-                             gl_cv_func_getopt_gnu="$gl_cross_guess_normal"
-
-else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <getopt.h>
-                           #include <stddef.h>
-                           #include <string.h>
+#include <sys/types.h>
+#include <sys/stat.h>
 
-#include <stdlib.h>
-#if defined __MACH__ && defined __APPLE__
-/* Avoid a crash on Mac OS X.  */
-#include <mach/mach.h>
-#include <mach/mach_error.h>
-#include <mach/thread_status.h>
-#include <mach/exception.h>
-#include <mach/task.h>
-#include <pthread.h>
-/* The exception port on which our thread listens.  */
-static mach_port_t our_exception_port;
-/* The main function of the thread listening for exceptions of type
-   EXC_BAD_ACCESS.  */
-static void *
-mach_exception_thread (void *arg)
-{
-  /* Buffer for a message to be received.  */
-  struct {
-    mach_msg_header_t head;
-    mach_msg_body_t msgh_body;
-    char data[1024];
-  } msg;
-  mach_msg_return_t retval;
-  /* Wait for a message on the exception port.  */
-  retval = mach_msg (&msg.head, MACH_RCV_MSG | MACH_RCV_LARGE, 0, sizeof (msg),
-                     our_exception_port, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
-  if (retval != MACH_MSG_SUCCESS)
-    abort ();
-  exit (1);
-}
-static void
-nocrash_init (void)
-{
-  mach_port_t self = mach_task_self ();
-  /* Allocate a port on which the thread shall listen for exceptions.  */
-  if (mach_port_allocate (self, MACH_PORT_RIGHT_RECEIVE, &our_exception_port)
-      == KERN_SUCCESS) {
-    /* See https://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_port_insert_right.html.  */
-    if (mach_port_insert_right (self, our_exception_port, our_exception_port,
-                                MACH_MSG_TYPE_MAKE_SEND)
-        == KERN_SUCCESS) {
-      /* The exceptions we want to catch.  Only EXC_BAD_ACCESS is interesting
-         for us.  */
-      exception_mask_t mask = EXC_MASK_BAD_ACCESS;
-      /* Create the thread listening on the exception port.  */
-      pthread_attr_t attr;
-      pthread_t thread;
-      if (pthread_attr_init (&attr) == 0
-          && pthread_attr_setdetachstate (&attr, PTHREAD_CREATE_DETACHED) == 0
-          && pthread_create (&thread, &attr, mach_exception_thread, NULL) == 0) {
-        pthread_attr_destroy (&attr);
-        /* Replace the exception port info for these exceptions with our own.
-           Note that we replace the exception port for the entire task, not only
-           for a particular thread.  This has the effect that when our exception
-           port gets the message, the thread specific exception port has already
-           been asked, and we don't need to bother about it.
-           See https://web.mit.edu/darwin/src/modules/xnu/osfmk/man/task_set_exception_ports.html.  */
-        task_set_exception_ports (self, mask, our_exception_port,
-                                  EXCEPTION_DEFAULT, MACHINE_THREAD_STATE);
-      }
-    }
-  }
-}
-#elif defined _WIN32 && ! defined __CYGWIN__
-/* Avoid a crash on native Windows.  */
-#define WIN32_LEAN_AND_MEAN
-#include <windows.h>
-#include <winerror.h>
-static LONG WINAPI
-exception_filter (EXCEPTION_POINTERS *ExceptionInfo)
-{
-  switch (ExceptionInfo->ExceptionRecord->ExceptionCode)
-    {
-    case EXCEPTION_ACCESS_VIOLATION:
-    case EXCEPTION_IN_PAGE_ERROR:
-    case EXCEPTION_STACK_OVERFLOW:
-    case EXCEPTION_GUARD_PAGE:
-    case EXCEPTION_PRIV_INSTRUCTION:
-    case EXCEPTION_ILLEGAL_INSTRUCTION:
-    case EXCEPTION_DATATYPE_MISALIGNMENT:
-    case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:
-    case EXCEPTION_NONCONTINUABLE_EXCEPTION:
-      exit (1);
-    }
-  return EXCEPTION_CONTINUE_SEARCH;
-}
-static void
-nocrash_init (void)
-{
-  SetUnhandledExceptionFilter ((LPTOP_LEVEL_EXCEPTION_FILTER) exception_filter);
-}
-#else
-/* Avoid a crash on POSIX systems.  */
-#include <signal.h>
-#include <unistd.h>
-/* A POSIX signal handler.  */
-static void
-exception_handler (int sig)
-{
-  _exit (1);
-}
-static void
-nocrash_init (void)
-{
-#ifdef SIGSEGV
-  signal (SIGSEGV, exception_handler);
-#endif
-#ifdef SIGBUS
-  signal (SIGBUS, exception_handler);
-#endif
-}
+#if defined S_ISBLK && defined S_IFDIR
+extern char c1[S_ISBLK (S_IFDIR) ? -1 : 1];
 #endif
 
+#if defined S_ISBLK && defined S_IFCHR
+extern char c2[S_ISBLK (S_IFCHR) ? -1 : 1];
+#endif
 
-int
-main (void)
-{
-
-             int result = 0;
-
-             nocrash_init();
-
-             /* This code succeeds on glibc 2.8, OpenBSD 4.0, Cygwin, mingw,
-                and fails on Mac OS X 10.5, AIX 5.2, HP-UX 11, IRIX 6.5,
-                OSF/1 5.1, Solaris 10.  */
-             {
-               static char conftest[] = "conftest";
-               static char plus[] = "-+";
-               char *argv[3] = { conftest, plus, NULL };
-               opterr = 0;
-               if (getopt (2, argv, "+a") != '?')
-                 result |= 1;
-             }
-             /* This code succeeds on glibc 2.8, mingw,
-                and fails on Mac OS X 10.5, OpenBSD 4.0, AIX 5.2, HP-UX 11,
-                IRIX 6.5, OSF/1 5.1, Solaris 10, Cygwin 1.5.x.  */
-             {
-               static char program[] = "program";
-               static char p[] = "-p";
-               static char foo[] = "foo";
-               static char bar[] = "bar";
-               char *argv[] = { program, p, foo, bar, NULL };
+#if defined S_ISLNK && defined S_IFREG
+extern char c3[S_ISLNK (S_IFREG) ? -1 : 1];
+#endif
 
-               optind = 1;
-               if (getopt (4, argv, "p::") != 'p')
-                 result |= 2;
-               else if (optarg != NULL)
-                 result |= 4;
-               else if (getopt (4, argv, "p::") != -1)
-                 result |= 6;
-               else if (optind != 2)
-                 result |= 8;
-             }
-             /* This code succeeds on glibc 2.8 and fails on Cygwin 1.7.0.  */
-             {
-               static char program[] = "program";
-               static char foo[] = "foo";
-               static char p[] = "-p";
-               char *argv[] = { program, foo, p, NULL };
-               optind = 0;
-               if (getopt (3, argv, "-p") != 1)
-                 result |= 16;
-               else if (getopt (3, argv, "-p") != 'p')
-                 result |= 16;
-             }
-             /* This code fails on glibc 2.11.  */
-             {
-               static char program[] = "program";
-               static char b[] = "-b";
-               static char a[] = "-a";
-               char *argv[] = { program, b, a, NULL };
-               optind = opterr = 0;
-               if (getopt (3, argv, "+:a:b") != 'b')
-                 result |= 32;
-               else if (getopt (3, argv, "+:a:b") != ':')
-                 result |= 32;
-             }
-             /* This code dumps core on glibc 2.14.  */
-             {
-               static char program[] = "program";
-               static char w[] = "-W";
-               static char dummy[] = "dummy";
-               char *argv[] = { program, w, dummy, NULL };
-               optind = opterr = 1;
-               if (getopt (3, argv, "W;") != 'W')
-                 result |= 64;
-             }
-             return result;
+#if defined S_ISSOCK && defined S_IFREG
+extern char c4[S_ISSOCK (S_IFREG) ? -1 : 1];
+#endif
 
-  ;
-  return 0;
-}
 _ACEOF
-if ac_fn_c_try_run "$LINENO"
+if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_func_getopt_gnu=yes
+  ac_cv_header_stat_broken=no
 else $as_nop
-  gl_cv_func_getopt_gnu=no
+  ac_cv_header_stat_broken=yes
 fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_stat_broken" >&5
+printf "%s\n" "$ac_cv_header_stat_broken" >&6; }
+if test $ac_cv_header_stat_broken = yes; then
 
-       case $gl_had_POSIXLY_CORRECT in
-         exported) ;;
-         yes) { POSIXLY_CORRECT=; unset POSIXLY_CORRECT;}; POSIXLY_CORRECT=1 ;;
-         *) { POSIXLY_CORRECT=; unset POSIXLY_CORRECT;} ;;
-       esac
+printf "%s\n" "#define STAT_MACROS_BROKEN 1" >>confdefs.h
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_getopt_gnu" >&5
-printf "%s\n" "$gl_cv_func_getopt_gnu" >&6; }
-    if test "$gl_cv_func_getopt_gnu" != yes; then
-      gl_replace_getopt=yes
-    else
-      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working GNU getopt_long function" >&5
-printf %s "checking for working GNU getopt_long function... " >&6; }
-if test ${gl_cv_func_getopt_long_gnu+y}
+
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for C/C++ restrict keyword" >&5
+printf %s "checking for C/C++ restrict keyword... " >&6; }
+if test ${ac_cv_c_restrict+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  if test "$cross_compiling" = yes
-then :
-              case "$host_os" in
-              openbsd*) gl_cv_func_getopt_long_gnu="guessing no";;
-              *)        gl_cv_func_getopt_long_gnu="guessing yes";;
-            esac
-
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  ac_cv_c_restrict=no
+   # Put '__restrict__' first, to avoid problems with glibc and non-GCC; see:
+   # https://lists.gnu.org/archive/html/bug-autoconf/2016-02/msg00006.html
+   # Put 'restrict' last, because C++ lacks it.
+   for ac_kw in __restrict__ __restrict _Restrict restrict; do
+     cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <getopt.h>
-                #include <stddef.h>
-                #include <string.h>
+typedef int *int_ptr;
+	   int foo (int_ptr $ac_kw ip) { return ip[0]; }
+	   int bar (int [$ac_kw]); /* Catch GCC bug 14050.  */
+	   int bar (int ip[$ac_kw]) { return ip[0]; }
 
 int
 main (void)
 {
-static const struct option long_options[] =
-                  {
-                    { "xtremely-",no_argument,       NULL, 1003 },
-                    { "xtra",     no_argument,       NULL, 1001 },
-                    { "xtreme",   no_argument,       NULL, 1002 },
-                    { "xtremely", no_argument,       NULL, 1003 },
-                    { NULL,       0,                 NULL, 0 }
-                  };
-                /* This code fails on OpenBSD 5.0.  */
-                {
-                  static char program[] = "program";
-                  static char xtremel[] = "--xtremel";
-                  char *argv[] = { program, xtremel, NULL };
-                  int option_index;
-                  optind = 1; opterr = 0;
-                  if (getopt_long (2, argv, "", long_options, &option_index) != 1003)
-                    return 1;
-                }
-                return 0;
+int s[1];
+	   int *$ac_kw t = s;
+	   t[0] = 0;
+	   return foo (t) + bar (t);
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"
+if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_func_getopt_long_gnu=yes
-else $as_nop
-  gl_cv_func_getopt_long_gnu=no
+  ac_cv_c_restrict=$ac_kw
 fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+     test "$ac_cv_c_restrict" != no && break
+   done
+
 fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_c_restrict" >&5
+printf "%s\n" "$ac_cv_c_restrict" >&6; }
+
+ case $ac_cv_c_restrict in
+   restrict) ;;
+   no) printf "%s\n" "#define restrict /**/" >>confdefs.h
+ ;;
+   *)  printf "%s\n" "#define restrict $ac_cv_c_restrict" >>confdefs.h
+ ;;
+ esac
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+     if test $gl_cv_have_include_next = yes; then
+       gl_cv_next_sys_stat_h='<'sys/stat.h'>'
+     else
+       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking absolute name of <sys/stat.h>" >&5
+printf %s "checking absolute name of <sys/stat.h>... " >&6; }
+if test ${gl_cv_next_sys_stat_h+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+
+             if test $ac_cv_header_sys_stat_h = yes; then
+
+
+
+
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <sys/stat.h>
+_ACEOF
+                case "$host_os" in
+    aix*) gl_absname_cpp="$ac_cpp -C" ;;
+    *)    gl_absname_cpp="$ac_cpp" ;;
+  esac
+
+  case "$host_os" in
+    mingw*)
+                                          gl_dirsep_regex='[/\\]'
+      ;;
+    *)
+      gl_dirsep_regex='\/'
+      ;;
+  esac
+      gl_make_literal_regex_sed='s,[]$^\\.*/[],\\&,g'
+  gl_header_literal_regex=`echo 'sys/stat.h' \
+                           | sed -e "$gl_make_literal_regex_sed"`
+  gl_absolute_header_sed="/${gl_dirsep_regex}${gl_header_literal_regex}/"'{
+      s/.*"\(.*'"${gl_dirsep_regex}${gl_header_literal_regex}"'\)".*/\1/
+      s|^/[^/]|//&|
+      p
+      q
+    }'
+
+        gl_cv_absolute_sys_stat_h=`(eval "$gl_absname_cpp conftest.$ac_ext") 2>&5 |
+  sed -n "$gl_absolute_header_sed"`
+
+           gl_header=$gl_cv_absolute_sys_stat_h
+           gl_cv_next_sys_stat_h='"'$gl_header'"'
+          else
+               gl_cv_next_sys_stat_h='<'sys/stat.h'>'
+             fi
 
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_getopt_long_gnu" >&5
-printf "%s\n" "$gl_cv_func_getopt_long_gnu" >&6; }
-      case "$gl_cv_func_getopt_long_gnu" in
-        *yes) ;;
-        *) gl_replace_getopt=yes ;;
-      esac
-    fi
-  fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_next_sys_stat_h" >&5
+printf "%s\n" "$gl_cv_next_sys_stat_h" >&6; }
+     fi
+     NEXT_SYS_STAT_H=$gl_cv_next_sys_stat_h
+
+     if test $gl_cv_have_include_next = yes || test $gl_cv_have_include_next = buggy; then
+       # INCLUDE_NEXT_AS_FIRST_DIRECTIVE='include_next'
+       gl_next_as_first_directive='<'sys/stat.h'>'
+     else
+       # INCLUDE_NEXT_AS_FIRST_DIRECTIVE='include'
+       gl_next_as_first_directive=$gl_cv_next_sys_stat_h
+     fi
+     NEXT_AS_FIRST_DIRECTIVE_SYS_STAT_H=$gl_next_as_first_directive
 
 
 
 
 
-    HAVE_GETRANDOM=1;
-  REPLACE_GETRANDOM=0;
 
 
 
+    WINDOWS_STAT_TIMESPEC=0
 
-  GL_M4_GNULIB_GETRANDOM=0
 
 
 
@@ -15717,327 +15836,534 @@
 
 
 
-  if test -z "$gl_pthreadlib_body_done"; then
-    gl_pthread_api=no
-    LIBPTHREAD=
-    LIBPMULTITHREAD=
-    # On OSF/1, the compiler needs the flag -pthread or -D_REENTRANT so that
-    # it groks <pthread.h>. It's added above, in gl_ANYTHREADLIB_EARLY.
-    ac_fn_c_check_header_compile "$LINENO" "pthread.h" "ac_cv_header_pthread_h" "$ac_includes_default"
-if test "x$ac_cv_header_pthread_h" = xyes
+      ac_fn_c_check_type "$LINENO" "nlink_t" "ac_cv_type_nlink_t" "#include <sys/types.h>
+     #include <sys/stat.h>
+"
+if test "x$ac_cv_type_nlink_t" = xyes
 then :
-  gl_have_pthread_h=yes
+
 else $as_nop
-  gl_have_pthread_h=no
+
+printf "%s\n" "#define nlink_t int" >>confdefs.h
+
 fi
 
-    if test "$gl_have_pthread_h" = yes; then
-      # Other possible tests:
-      #   -lpthreads (FSU threads, PCthreads)
-      #   -lgthreads
-      # Test whether both pthread_mutex_lock and pthread_mutexattr_init exist
-      # in libc. IRIX 6.5 has the first one in both libc and libpthread, but
-      # the second one only in libpthread, and lock.c needs it.
-      #
-      # If -pthread works, prefer it to -lpthread, since Ubuntu 14.04
-      # needs -pthread for some reason.  See:
-      # https://lists.gnu.org/r/bug-gnulib/2014-09/msg00023.html
-      save_LIBS=$LIBS
-      for gl_pthread in '' '-pthread'; do
-        LIBS="$LIBS $gl_pthread"
-        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <pthread.h>
-               pthread_mutex_t m;
-               pthread_mutexattr_t ma;
 
-int
-main (void)
-{
-pthread_mutex_lock (&m);
-               pthread_mutexattr_init (&ma);
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"
+
+
+
+
+
+
+  case "$host_os" in
+    mingw*)
+      ac_fn_c_check_header_compile "$LINENO" "sdkddkver.h" "ac_cv_header_sdkddkver_h" "$ac_includes_default"
+if test "x$ac_cv_header_sdkddkver_h" = xyes
 then :
-  gl_pthread_api=yes
-           LIBPTHREAD=$gl_pthread
-           LIBPMULTITHREAD=$gl_pthread
+  printf "%s\n" "#define HAVE_SDKDDKVER_H 1" >>confdefs.h
+
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
-        LIBS=$save_LIBS
-        test $gl_pthread_api = yes && break
-      done
 
-      # Test for libpthread by looking for pthread_kill. (Not pthread_self,
-      # since it is defined as a macro on OSF/1.)
-      if test $gl_pthread_api = yes && test -z "$LIBPTHREAD"; then
-        # The program links fine without libpthread. But it may actually
-        # need to link with libpthread in order to create multiple threads.
-        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for pthread_kill in -lpthread" >&5
-printf %s "checking for pthread_kill in -lpthread... " >&6; }
-if test ${ac_cv_lib_pthread_pthread_kill+y}
+      ;;
+  esac
+
+
+
+
+
+
+
+  GL_M4_GNULIB_FCHMODAT=0
+
+
+
+  GL_M4_GNULIB_FSTAT=0
+
+
+
+  GL_M4_GNULIB_FSTATAT=0
+
+
+
+  GL_M4_GNULIB_FUTIMENS=0
+
+
+
+  GL_M4_GNULIB_GETUMASK=0
+
+
+
+  GL_M4_GNULIB_LCHMOD=0
+
+
+
+  GL_M4_GNULIB_LSTAT=0
+
+
+
+  GL_M4_GNULIB_MKDIR=0
+
+
+
+  GL_M4_GNULIB_MKDIRAT=0
+
+
+
+  GL_M4_GNULIB_MKFIFO=0
+
+
+
+  GL_M4_GNULIB_MKFIFOAT=0
+
+
+
+  GL_M4_GNULIB_MKNOD=0
+
+
+
+  GL_M4_GNULIB_MKNODAT=0
+
+
+
+  GL_M4_GNULIB_STAT=0
+
+
+
+  GL_M4_GNULIB_UTIMENSAT=0
+
+
+
+  GL_M4_GNULIB_OVERRIDES_STRUCT_STAT=0
+
+
+
+  GL_M4_GNULIB_MDA_CHMOD=1
+
+
+
+  GL_M4_GNULIB_MDA_MKDIR=1
+
+
+
+  GL_M4_GNULIB_MDA_UMASK=1
+
+
+
+
+ac_fn_check_decl "$LINENO" "ftello" "ac_cv_have_decl_ftello" "$ac_includes_default" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_ftello" = xyes
+then :
+  ac_have_decl=1
+else $as_nop
+  ac_have_decl=0
+fi
+printf "%s\n" "#define HAVE_DECL_FTELLO $ac_have_decl" >>confdefs.h
+
+
+
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ungetc works on arbitrary bytes" >&5
+printf %s "checking whether ungetc works on arbitrary bytes... " >&6; }
+if test ${gl_cv_func_ungetc_works+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  ac_check_lib_save_LIBS=$LIBS
-LIBS="-lpthread  $LIBS"
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  if test "$cross_compiling" = yes
+then :
+  case "$host_os" in
+                          # Guess yes on glibc systems.
+           *-gnu* | gnu*) gl_cv_func_ungetc_works="guessing yes" ;;
+                          # Guess yes on musl systems.
+           *-musl*)       gl_cv_func_ungetc_works="guessing yes" ;;
+                          # Guess yes on bionic systems.
+           *-android*)    gl_cv_func_ungetc_works="guessing yes" ;;
+                          # Guess yes on native Windows.
+           mingw*)        gl_cv_func_ungetc_works="guessing yes" ;;
+                          # If we don't know, obey --enable-cross-guesses.
+           *)             gl_cv_func_ungetc_works="$gl_cross_guess_normal" ;;
+         esac
+
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-char pthread_kill ();
+#include <stdio.h>
+
 int
 main (void)
 {
-return pthread_kill ();
+FILE *f;
+            if (!(f = fopen ("conftest.tmp", "w+")))
+              return 1;
+            if (fputs ("abc", f) < 0)
+              { fclose (f); return 2; }
+            rewind (f);
+            if (fgetc (f) != 'a')
+              { fclose (f); return 3; }
+            if (fgetc (f) != 'b')
+              { fclose (f); return 4; }
+            if (ungetc ('d', f) != 'd')
+              { fclose (f); return 5; }
+            if (ftell (f) != 1)
+              { fclose (f); return 6; }
+            if (fgetc (f) != 'd')
+              { fclose (f); return 7; }
+            if (ftell (f) != 2)
+              { fclose (f); return 8; }
+            if (fseek (f, 0, SEEK_CUR) != 0)
+              { fclose (f); return 9; }
+            if (ftell (f) != 2)
+              { fclose (f); return 10; }
+            if (fgetc (f) != 'c')
+              { fclose (f); return 11; }
+            fclose (f);
+            remove ("conftest.tmp");
+
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"
+if ac_fn_c_try_run "$LINENO"
 then :
-  ac_cv_lib_pthread_pthread_kill=yes
+  gl_cv_func_ungetc_works=yes
 else $as_nop
-  ac_cv_lib_pthread_pthread_kill=no
+  gl_cv_func_ungetc_works=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
-LIBS=$ac_check_lib_save_LIBS
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_pthread_pthread_kill" >&5
-printf "%s\n" "$ac_cv_lib_pthread_pthread_kill" >&6; }
-if test "x$ac_cv_lib_pthread_pthread_kill" = xyes
-then :
-  LIBPMULTITHREAD=-lpthread
-           # On Solaris and HP-UX, most pthread functions exist also in libc.
-           # Therefore pthread_in_use() needs to actually try to create a
-           # thread: pthread_create from libc will fail, whereas
-           # pthread_create will actually create a thread.
-           # On Solaris 10 or newer, this test is no longer needed, because
-           # libc contains the fully functional pthread functions.
-           case "$host_os" in
-             solaris | solaris2.1-9 | solaris2.1-9.* | hpux*)
-
-printf "%s\n" "#define PTHREAD_IN_USE_DETECTION_HARD 1" >>confdefs.h
 
-           esac
 
 fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ungetc_works" >&5
+printf "%s\n" "$gl_cv_func_ungetc_works" >&6; }
+  gl_ftello_broken_after_ungetc=no
+  case "$gl_cv_func_ungetc_works" in
+    *yes) ;;
+    *)
+                  case "$host_os" in
+        darwin*) gl_ftello_broken_after_ungetc=yes ;;
+        *)
 
-      elif test $gl_pthread_api != yes; then
-        # Some library is needed. Try libpthread and libc_r.
-        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for pthread_kill in -lpthread" >&5
-printf %s "checking for pthread_kill in -lpthread... " >&6; }
-if test ${ac_cv_lib_pthread_pthread_kill+y}
+printf "%s\n" "#define FUNC_UNGETC_BROKEN 1" >>confdefs.h
+
+          ;;
+      esac
+      ;;
+  esac
+
+
+
+
+
+
+
+
+
+
+  if test $ac_cv_have_decl_ftello = no; then
+    HAVE_DECL_FTELLO=0
+  fi
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for ftello" >&5
+printf %s "checking for ftello... " >&6; }
+if test ${gl_cv_func_ftello+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  ac_check_lib_save_LIBS=$LIBS
-LIBS="-lpthread  $LIBS"
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
 
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-char pthread_kill ();
+      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <stdio.h>
 int
 main (void)
 {
-return pthread_kill ();
+ftello (stdin);
   ;
   return 0;
 }
 _ACEOF
 if ac_fn_c_try_link "$LINENO"
 then :
-  ac_cv_lib_pthread_pthread_kill=yes
+  gl_cv_func_ftello=yes
 else $as_nop
-  ac_cv_lib_pthread_pthread_kill=no
+  gl_cv_func_ftello=no
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
-LIBS=$ac_check_lib_save_LIBS
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_pthread_pthread_kill" >&5
-printf "%s\n" "$ac_cv_lib_pthread_pthread_kill" >&6; }
-if test "x$ac_cv_lib_pthread_pthread_kill" = xyes
-then :
-  gl_pthread_api=yes
-           LIBPTHREAD=-lpthread
-           LIBPMULTITHREAD=-lpthread
+
 fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ftello" >&5
+printf "%s\n" "$gl_cv_func_ftello" >&6; }
+  if test $gl_cv_func_ftello = no; then
+    HAVE_FTELLO=0
+  else
+    if test $WINDOWS_64_BIT_OFF_T = 1; then
+      REPLACE_FTELLO=1
+    fi
+    if test $gl_cv_var_stdin_large_offset = no; then
+      REPLACE_FTELLO=1
+    fi
+    if test $REPLACE_FTELLO = 0; then
 
-        if test $gl_pthread_api != yes; then
-          # For FreeBSD 4.
-          { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for pthread_kill in -lc_r" >&5
-printf %s "checking for pthread_kill in -lc_r... " >&6; }
-if test ${ac_cv_lib_c_r_pthread_kill+y}
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ftello works" >&5
+printf %s "checking whether ftello works... " >&6; }
+if test ${gl_cv_func_ftello_works+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  ac_check_lib_save_LIBS=$LIBS
-LIBS="-lc_r  $LIBS"
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+
+                              case "$host_os" in
+                      # Guess no on Solaris.
+            solaris*) gl_cv_func_ftello_works="guessing no" ;;
+                      # Guess yes on native Windows.
+            mingw*)   gl_cv_func_ftello_works="guessing yes" ;;
+                      # Guess yes otherwise.
+            *)        gl_cv_func_ftello_works="guessing yes" ;;
+          esac
+          if test "$cross_compiling" = yes
+then :
+  :
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-char pthread_kill ();
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#define TESTFILE "conftest.tmp"
 int
 main (void)
 {
-return pthread_kill ();
-  ;
+  FILE *fp;
+
+  /* Create a file with some contents.  */
+  fp = fopen (TESTFILE, "w");
+  if (fp == NULL)
+    return 70;
+  if (fwrite ("foogarsh", 1, 8, fp) < 8)
+    { fclose (fp); return 71; }
+  if (fclose (fp))
+    return 72;
+
+  /* The file's contents is now "foogarsh".  */
+
+  /* Try writing after reading to EOF.  */
+  fp = fopen (TESTFILE, "r+");
+  if (fp == NULL)
+    return 73;
+  if (fseek (fp, -1, SEEK_END))
+    { fclose (fp); return 74; }
+  if (!(getc (fp) == 'h'))
+    { fclose (fp); return 1; }
+  if (!(getc (fp) == EOF))
+    { fclose (fp); return 2; }
+  if (!(ftell (fp) == 8))
+    { fclose (fp); return 3; }
+  if (!(ftell (fp) == 8))
+    { fclose (fp); return 4; }
+  if (!(putc ('!', fp) == '!'))
+    { fclose (fp); return 5; }
+  if (!(ftell (fp) == 9))
+    { fclose (fp); return 6; }
+  if (!(fclose (fp) == 0))
+    return 7;
+  fp = fopen (TESTFILE, "r");
+  if (fp == NULL)
+    return 75;
+  {
+    char buf[10];
+    if (!(fread (buf, 1, 10, fp) == 9))
+      { fclose (fp); return 10; }
+    if (!(memcmp (buf, "foogarsh!", 9) == 0))
+      { fclose (fp); return 11; }
+  }
+  if (!(fclose (fp) == 0))
+    return 12;
+
+  /* The file's contents is now "foogarsh!".  */
+
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"
+if ac_fn_c_try_run "$LINENO"
 then :
-  ac_cv_lib_c_r_pthread_kill=yes
+  gl_cv_func_ftello_works=yes
 else $as_nop
-  ac_cv_lib_c_r_pthread_kill=no
+  gl_cv_func_ftello_works=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
-LIBS=$ac_check_lib_save_LIBS
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_c_r_pthread_kill" >&5
-printf "%s\n" "$ac_cv_lib_c_r_pthread_kill" >&6; }
-if test "x$ac_cv_lib_c_r_pthread_kill" = xyes
-then :
-  gl_pthread_api=yes
-             LIBPTHREAD=-lc_r
-             LIBPMULTITHREAD=-lc_r
+
+
 fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ftello_works" >&5
+printf "%s\n" "$gl_cv_func_ftello_works" >&6; }
+      case "$gl_cv_func_ftello_works" in
+        *yes) ;;
+        *)
+          REPLACE_FTELLO=1
 
-        fi
-      fi
-    fi
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether POSIX threads API is available" >&5
-printf %s "checking whether POSIX threads API is available... " >&6; }
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_pthread_api" >&5
-printf "%s\n" "$gl_pthread_api" >&6; }
+printf "%s\n" "#define FTELLO_BROKEN_AFTER_SWITCHING_FROM_READ_TO_WRITE 1" >>confdefs.h
 
+          ;;
+      esac
+    fi
+    if test $REPLACE_FTELLO = 0; then
 
-    if test $gl_pthread_api = yes; then
+      if test $gl_ftello_broken_after_ungetc = yes; then
+        REPLACE_FTELLO=1
 
-printf "%s\n" "#define HAVE_PTHREAD_API 1" >>confdefs.h
+printf "%s\n" "#define FTELLO_BROKEN_AFTER_UNGETC 1" >>confdefs.h
 
+      fi
     fi
+  fi
 
-        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sched.h>
-int
-main (void)
-{
-sched_yield ();
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"
-then :
-  LIB_SCHED_YIELD=
 
-else $as_nop
-         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for sched_yield in -lrt" >&5
-printf %s "checking for sched_yield in -lrt... " >&6; }
-if test ${ac_cv_lib_rt_sched_yield+y}
+
+   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether getcwd (NULL, 0) allocates memory for result" >&5
+printf %s "checking whether getcwd (NULL, 0) allocates memory for result... " >&6; }
+if test ${gl_cv_func_getcwd_null+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  ac_check_lib_save_LIBS=$LIBS
-LIBS="-lrt  $LIBS"
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  if test "$cross_compiling" = yes
+then :
+  case "$host_os" in
+                           # Guess yes on glibc systems.
+            *-gnu* | gnu*) gl_cv_func_getcwd_null="guessing yes";;
+                           # Guess yes on musl systems.
+            *-musl*)       gl_cv_func_getcwd_null="guessing yes";;
+                           # Guess yes on Cygwin.
+            cygwin*)       gl_cv_func_getcwd_null="guessing yes";;
+                           # If we don't know, obey --enable-cross-guesses.
+            *)             gl_cv_func_getcwd_null="$gl_cross_guess_normal";;
+          esac
+
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-char sched_yield ();
+#	 include <stdlib.h>
+#        if HAVE_UNISTD_H
+#         include <unistd.h>
+#        else /* on Windows with MSVC */
+#         include <direct.h>
+#        endif
+
+
+$gl_mda_defines
+
+#        ifndef getcwd
+         char *getcwd ();
+#        endif
+
 int
 main (void)
 {
-return sched_yield ();
+
+#if defined _WIN32 && ! defined __CYGWIN__
+/* mingw cwd does not start with '/', but _getcwd does allocate.
+   However, mingw fails to honor non-zero size.  */
+#else
+           if (chdir ("/") != 0)
+             return 1;
+           else
+             {
+               char *f = getcwd (NULL, 0);
+               if (! f)
+                 return 2;
+               if (f[0] != '/')
+                 { free (f); return 3; }
+               if (f[1] != '\0')
+                 { free (f); return 4; }
+               free (f);
+               return 0;
+             }
+#endif
+
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"
+if ac_fn_c_try_run "$LINENO"
 then :
-  ac_cv_lib_rt_sched_yield=yes
+  gl_cv_func_getcwd_null=yes
 else $as_nop
-  ac_cv_lib_rt_sched_yield=no
+  gl_cv_func_getcwd_null=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
-LIBS=$ac_check_lib_save_LIBS
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_rt_sched_yield" >&5
-printf "%s\n" "$ac_cv_lib_rt_sched_yield" >&6; }
-if test "x$ac_cv_lib_rt_sched_yield" = xyes
-then :
-  LIB_SCHED_YIELD=-lrt
-else $as_nop
-            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for sched_yield in -lposix4" >&5
-printf %s "checking for sched_yield in -lposix4... " >&6; }
-if test ${ac_cv_lib_posix4_sched_yield+y}
+
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_getcwd_null" >&5
+printf "%s\n" "$gl_cv_func_getcwd_null" >&6; }
+
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for getcwd with POSIX signature" >&5
+printf %s "checking for getcwd with POSIX signature... " >&6; }
+if test ${gl_cv_func_getcwd_posix_signature+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  ac_check_lib_save_LIBS=$LIBS
-LIBS="-lposix4  $LIBS"
-cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
+#include <unistd.h>
+
+
+$gl_mda_defines
 
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-char sched_yield ();
 int
 main (void)
 {
-return sched_yield ();
+extern
+           #ifdef __cplusplus
+           "C"
+           #endif
+           char *getcwd (char *, size_t);
+
   ;
   return 0;
 }
+
 _ACEOF
-if ac_fn_c_try_link "$LINENO"
+if ac_fn_c_try_compile "$LINENO"
 then :
-  ac_cv_lib_posix4_sched_yield=yes
+  gl_cv_func_getcwd_posix_signature=yes
 else $as_nop
-  ac_cv_lib_posix4_sched_yield=no
+  gl_cv_func_getcwd_posix_signature=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
-LIBS=$ac_check_lib_save_LIBS
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_posix4_sched_yield" >&5
-printf "%s\n" "$ac_cv_lib_posix4_sched_yield" >&6; }
-if test "x$ac_cv_lib_posix4_sched_yield" = xyes
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_getcwd_posix_signature" >&5
+printf "%s\n" "$gl_cv_func_getcwd_posix_signature" >&6; }
+
+ac_fn_check_decl "$LINENO" "getcwd" "ac_cv_have_decl_getcwd" "$ac_includes_default" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_getcwd" = xyes
 then :
-  LIB_SCHED_YIELD=-lposix4
+  ac_have_decl=1
+else $as_nop
+  ac_have_decl=0
 fi
+printf "%s\n" "#define HAVE_DECL_GETCWD $ac_have_decl" >>confdefs.h
+
 
+ac_fn_check_decl "$LINENO" "getdtablesize" "ac_cv_have_decl_getdtablesize" "$ac_includes_default" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_getdtablesize" = xyes
+then :
+  ac_have_decl=1
+else $as_nop
+  ac_have_decl=0
 fi
+printf "%s\n" "#define HAVE_DECL_GETDTABLESIZE $ac_have_decl" >>confdefs.h
 
 
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
 
 
-    gl_pthreadlib_body_done=done
-  fi
 
 
 
@@ -16046,965 +16372,1270 @@
 
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether setlocale (LC_ALL, NULL) is multithread-safe" >&5
-printf %s "checking whether setlocale (LC_ALL, NULL) is multithread-safe... " >&6; }
-if test ${gl_cv_func_setlocale_null_all_mtsafe+y}
+
+
+
+     if test $gl_cv_have_include_next = yes; then
+       gl_cv_next_getopt_h='<'getopt.h'>'
+     else
+       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking absolute name of <getopt.h>" >&5
+printf %s "checking absolute name of <getopt.h>... " >&6; }
+if test ${gl_cv_next_getopt_h+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  case "$host_os" in
-       # Guess no on musl libc, macOS, FreeBSD, NetBSD, OpenBSD, AIX, Haiku, Cygwin.
-       *-musl* | darwin* | freebsd* | midnightbsd* | netbsd* | openbsd* | aix* | haiku* | cygwin*)
-         gl_cv_func_setlocale_null_all_mtsafe=no ;;
-       # Guess yes on glibc, HP-UX, IRIX, Solaris, native Windows.
-       *-gnu* | gnu* | hpux* | irix* | solaris* | mingw*)
-         gl_cv_func_setlocale_null_all_mtsafe=yes ;;
-       # If we don't know, obey --enable-cross-guesses.
-       *)
-         gl_cv_func_setlocale_null_all_mtsafe="$gl_cross_guess_normal" ;;
-     esac
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_setlocale_null_all_mtsafe" >&5
-printf "%s\n" "$gl_cv_func_setlocale_null_all_mtsafe" >&6; }
-    case "$host_os" in
-    mingw*) ;;
+             if test $ac_cv_header_getopt_h = yes; then
+
+
+
+
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <getopt.h>
+_ACEOF
+                case "$host_os" in
+    aix*) gl_absname_cpp="$ac_cpp -C" ;;
+    *)    gl_absname_cpp="$ac_cpp" ;;
+  esac
+
+  case "$host_os" in
+    mingw*)
+                                          gl_dirsep_regex='[/\\]'
+      ;;
     *)
-      if test $gl_pthread_api = no && test $ac_cv_header_threads_h = no; then
-        gl_cv_func_setlocale_null_all_mtsafe="trivially yes"
-      fi
+      gl_dirsep_regex='\/'
       ;;
   esac
-  case "$gl_cv_func_setlocale_null_all_mtsafe" in
-    *yes) SETLOCALE_NULL_ALL_MTSAFE=1 ;;
-    *)    SETLOCALE_NULL_ALL_MTSAFE=0 ;;
-  esac
+      gl_make_literal_regex_sed='s,[]$^\\.*/[],\\&,g'
+  gl_header_literal_regex=`echo 'getopt.h' \
+                           | sed -e "$gl_make_literal_regex_sed"`
+  gl_absolute_header_sed="/${gl_dirsep_regex}${gl_header_literal_regex}/"'{
+      s/.*"\(.*'"${gl_dirsep_regex}${gl_header_literal_regex}"'\)".*/\1/
+      s|^/[^/]|//&|
+      p
+      q
+    }'
 
-printf "%s\n" "#define SETLOCALE_NULL_ALL_MTSAFE $SETLOCALE_NULL_ALL_MTSAFE" >>confdefs.h
+        gl_cv_absolute_getopt_h=`(eval "$gl_absname_cpp conftest.$ac_ext") 2>&5 |
+  sed -n "$gl_absolute_header_sed"`
+
+           gl_header=$gl_cv_absolute_getopt_h
+           gl_cv_next_getopt_h='"'$gl_header'"'
+          else
+               gl_cv_next_getopt_h='<'getopt.h'>'
+             fi
 
 
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether setlocale (category, NULL) is multithread-safe" >&5
-printf %s "checking whether setlocale (category, NULL) is multithread-safe... " >&6; }
-if test ${gl_cv_func_setlocale_null_one_mtsafe+y}
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_next_getopt_h" >&5
+printf "%s\n" "$gl_cv_next_getopt_h" >&6; }
+     fi
+     NEXT_GETOPT_H=$gl_cv_next_getopt_h
+
+     if test $gl_cv_have_include_next = yes || test $gl_cv_have_include_next = buggy; then
+       # INCLUDE_NEXT_AS_FIRST_DIRECTIVE='include_next'
+       gl_next_as_first_directive='<'getopt.h'>'
+     else
+       # INCLUDE_NEXT_AS_FIRST_DIRECTIVE='include'
+       gl_next_as_first_directive=$gl_cv_next_getopt_h
+     fi
+     NEXT_AS_FIRST_DIRECTIVE_GETOPT_H=$gl_next_as_first_directive
+
+
+
+
+  if test $ac_cv_header_getopt_h = yes; then
+    HAVE_GETOPT_H=1
+  else
+    HAVE_GETOPT_H=0
+  fi
+
+
+  gl_replace_getopt=
+
+    if test -z "$gl_replace_getopt" && test $gl_getopt_required = GNU; then
+           for ac_header in getopt.h
+do :
+  ac_fn_c_check_header_compile "$LINENO" "getopt.h" "ac_cv_header_getopt_h" "$ac_includes_default"
+if test "x$ac_cv_header_getopt_h" = xyes
 then :
-  printf %s "(cached) " >&6
+  printf "%s\n" "#define HAVE_GETOPT_H 1" >>confdefs.h
+
 else $as_nop
-  case "$host_os" in
-       # Guess no on OpenBSD, AIX.
-       openbsd* | aix*)
-         gl_cv_func_setlocale_null_one_mtsafe=no ;;
-       # Guess yes on glibc, musl libc, macOS, FreeBSD, NetBSD, HP-UX, IRIX, Solaris, Haiku, Cygwin, native Windows.
-       *-gnu* | gnu* | *-musl* | darwin* | freebsd* | midnightbsd* | netbsd* | hpux* | irix* | solaris* | haiku* | cygwin* | mingw*)
-         gl_cv_func_setlocale_null_one_mtsafe=yes ;;
-       # If we don't know, obey --enable-cross-guesses.
-       *)
-         gl_cv_func_setlocale_null_one_mtsafe="$gl_cross_guess_normal" ;;
-     esac
+  gl_replace_getopt=yes
+fi
+
+done
+  fi
+
+    if test -z "$gl_replace_getopt" && test $gl_getopt_required = GNU; then
+
+  for ac_func in getopt_long_only
+do :
+  ac_fn_c_check_func "$LINENO" "getopt_long_only" "ac_cv_func_getopt_long_only"
+if test "x$ac_cv_func_getopt_long_only" = xyes
+then :
+  printf "%s\n" "#define HAVE_GETOPT_LONG_ONLY 1" >>confdefs.h
 
+else $as_nop
+  gl_replace_getopt=yes
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_setlocale_null_one_mtsafe" >&5
-printf "%s\n" "$gl_cv_func_setlocale_null_one_mtsafe" >&6; }
-    case "$host_os" in
-    mingw*) ;;
-    *)
-      if test $gl_pthread_api = no && test $ac_cv_header_threads_h = no; then
-        gl_cv_func_setlocale_null_one_mtsafe="trivially yes"
-      fi
-      ;;
-  esac
-  case "$gl_cv_func_setlocale_null_one_mtsafe" in
-    *yes) SETLOCALE_NULL_ONE_MTSAFE=1 ;;
-    *)    SETLOCALE_NULL_ONE_MTSAFE=0 ;;
-  esac
 
-printf "%s\n" "#define SETLOCALE_NULL_ONE_MTSAFE $SETLOCALE_NULL_ONE_MTSAFE" >>confdefs.h
+done
+  fi
 
+          if test -z "$gl_replace_getopt"; then
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether getopt is POSIX compatible" >&5
+printf %s "checking whether getopt is POSIX compatible... " >&6; }
+if test ${gl_cv_func_getopt_posix+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
-    if test $SETLOCALE_NULL_ALL_MTSAFE = 0 || test $SETLOCALE_NULL_ONE_MTSAFE = 0; then
-    case "$host_os" in
-      mingw*) LIB_SETLOCALE_NULL= ;;
-      *)
+                                                if test $cross_compiling = no; then
+                              if test "$cross_compiling" = yes
+then :
+  { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "cannot run test program while cross compiling
+See \`config.log' for more details" "$LINENO" 5; }
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
+#include <unistd.h>
+#include <stdlib.h>
+#include <string.h>
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether imported symbols can be declared weak" >&5
-printf %s "checking whether imported symbols can be declared weak... " >&6; }
-if test ${gl_cv_have_weak+y}
+int
+main ()
+{
+  static char program[] = "program";
+  static char a[] = "-a";
+  static char foo[] = "foo";
+  static char bar[] = "bar";
+  char *argv[] = { program, a, foo, bar, NULL };
+  int c;
+
+  c = getopt (4, argv, "ab");
+  if (!(c == 'a'))
+    return 1;
+  c = getopt (4, argv, "ab");
+  if (!(c == -1))
+    return 2;
+  if (!(optind == 2))
+    return 3;
+  return 0;
+}
+
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
+then :
+  gl_cv_func_getopt_posix=maybe
+else $as_nop
+  gl_cv_func_getopt_posix=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
+
+          if test $gl_cv_func_getopt_posix = maybe; then
+                                    if test "$cross_compiling" = yes
 then :
-  printf %s "(cached) " >&6
+  { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "cannot run test program while cross compiling
+See \`config.log' for more details" "$LINENO" 5; }
 else $as_nop
-  gl_cv_have_weak=no
-          cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-extern void xyzzy ();
-#pragma weak xyzzy
+
+#include <unistd.h>
+#include <stdlib.h>
+#include <string.h>
+
 int
-main (void)
+main ()
 {
-xyzzy();
-  ;
+  static char program[] = "program";
+  static char donald[] = "donald";
+  static char p[] = "-p";
+  static char billy[] = "billy";
+  static char duck[] = "duck";
+  static char a[] = "-a";
+  static char bar[] = "bar";
+  char *argv[] = { program, donald, p, billy, duck, a, bar, NULL };
+  int c;
+
+  c = getopt (7, argv, "+abp:q:");
+  if (!(c == -1))
+    return 4;
+  if (!(strcmp (argv[0], "program") == 0))
+    return 5;
+  if (!(strcmp (argv[1], "donald") == 0))
+    return 6;
+  if (!(strcmp (argv[2], "-p") == 0))
+    return 7;
+  if (!(strcmp (argv[3], "billy") == 0))
+    return 8;
+  if (!(strcmp (argv[4], "duck") == 0))
+    return 9;
+  if (!(strcmp (argv[5], "-a") == 0))
+    return 10;
+  if (!(strcmp (argv[6], "bar") == 0))
+    return 11;
+  if (!(optind == 1))
+    return 12;
   return 0;
 }
-_ACEOF
-if ac_fn_c_try_link "$LINENO"
-then :
-  gl_cv_have_weak=maybe
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
-     if test $gl_cv_have_weak = maybe; then
-                     if test "$cross_compiling" = yes
-then :
-                      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#ifdef __ELF__
-             Extensible Linking Format
-             #endif
 
 _ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "Extensible Linking Format" >/dev/null 2>&1
+if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_have_weak="guessing yes"
+  gl_cv_func_getopt_posix=maybe
 else $as_nop
-  gl_cv_have_weak="guessing no"
+  gl_cv_func_getopt_posix=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -rf conftest*
-
 
+          fi
+          if test $gl_cv_func_getopt_posix = maybe; then
+                        if test "$cross_compiling" = yes
+then :
+  { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "cannot run test program while cross compiling
+See \`config.log' for more details" "$LINENO" 5; }
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
-#include <stdio.h>
-#pragma weak fputs
-int main ()
+#include <unistd.h>
+#include <stdlib.h>
+#include <string.h>
+
+int
+main ()
 {
-  return (fputs == NULL);
+  static char program[] = "program";
+  static char ab[] = "-ab";
+  char *argv[3] = { program, ab, NULL };
+  if (getopt (2, argv, "ab:") != 'a')
+    return 13;
+  if (getopt (2, argv, "ab:") != '?')
+    return 14;
+  if (optopt != 'b')
+    return 15;
+  if (optind != 2)
+    return 16;
+  return 0;
 }
+
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_have_weak=yes
+  gl_cv_func_getopt_posix=yes
 else $as_nop
-  gl_cv_have_weak=no
+  gl_cv_func_getopt_posix=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
-     fi
-          case " $LDFLAGS " in
-       *" -static "*) gl_cv_have_weak=no ;;
-     esac
-                    case "$gl_cv_have_weak" in
-       *yes)
-         case "$host_os" in
-           freebsd* | dragonfly* | midnightbsd*)
-             : > conftest1.c
-             $CC $CPPFLAGS $CFLAGS $LDFLAGS -fPIC -shared -o libempty.so conftest1.c -lpthread >&5 2>&1
-             cat <<EOF > conftest2.c
-#include <pthread.h>
-#pragma weak pthread_mutexattr_gettype
-int main ()
-{
-  return (pthread_mutexattr_gettype != NULL);
-}
-EOF
-             $CC $CPPFLAGS $CFLAGS $LDFLAGS -o conftest conftest2.c libempty.so >&5 2>&1 \
-               || gl_cv_have_weak=no
-             rm -f conftest1.c libempty.so conftest2.c conftest
-             ;;
-         esac
-         ;;
-     esac
+          fi
+        else
+          case "$host_os" in
+            darwin* | aix* | mingw*) gl_cv_func_getopt_posix="guessing no";;
+            *)                       gl_cv_func_getopt_posix="guessing yes";;
+          esac
+        fi
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_have_weak" >&5
-printf "%s\n" "$gl_cv_have_weak" >&6; }
-  case "$gl_cv_have_weak" in
-    *yes)
-
-printf "%s\n" "#define HAVE_WEAK_SYMBOLS 1" >>confdefs.h
-
-      ;;
-  esac
-
-        case "$gl_cv_have_weak" in
-          *yes) LIB_SETLOCALE_NULL= ;;
-          *)    LIB_SETLOCALE_NULL="$LIBPTHREAD" ;;
-        esac
-        ;;
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_getopt_posix" >&5
+printf "%s\n" "$gl_cv_func_getopt_posix" >&6; }
+    case "$gl_cv_func_getopt_posix" in
+      *no) gl_replace_getopt=yes ;;
     esac
-  else
-    LIB_SETLOCALE_NULL=
   fi
 
+  if test -z "$gl_replace_getopt" && test $gl_getopt_required = GNU; then
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working GNU getopt function" >&5
+printf %s "checking for working GNU getopt function... " >&6; }
+if test ${gl_cv_func_getopt_gnu+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  # Even with POSIXLY_CORRECT, the GNU extension of leading '-' in the
+       # optstring is necessary for programs like m4 that have POSIX-mandated
+       # semantics for supporting options interspersed with files.
+       # Also, since getopt_long is a GNU extension, we require optind=0.
+       # Bash ties 'set -o posix' to a non-exported POSIXLY_CORRECT;
+       # so take care to revert to the correct (non-)export state.
+       gl_awk_probe='BEGIN { if ("POSIXLY_CORRECT" in ENVIRON) print "x" }'
+       case ${POSIXLY_CORRECT+x}`$AWK "$gl_awk_probe" </dev/null` in
+         xx) gl_had_POSIXLY_CORRECT=exported ;;
+         x)  gl_had_POSIXLY_CORRECT=yes      ;;
+         *)  gl_had_POSIXLY_CORRECT=         ;;
+       esac
+       POSIXLY_CORRECT=1
+       export POSIXLY_CORRECT
+       if test "$cross_compiling" = yes
+then :
+                             gl_cv_func_getopt_gnu="$gl_cross_guess_normal"
 
-
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
+#include <getopt.h>
+                           #include <stddef.h>
+                           #include <string.h>
 
-#ifdef _MSC_VER
-MicrosoftCompiler
+#include <stdlib.h>
+#if defined __MACH__ && defined __APPLE__
+/* Avoid a crash on Mac OS X.  */
+#include <mach/mach.h>
+#include <mach/mach_error.h>
+#include <mach/thread_status.h>
+#include <mach/exception.h>
+#include <mach/task.h>
+#include <pthread.h>
+/* The exception port on which our thread listens.  */
+static mach_port_t our_exception_port;
+/* The main function of the thread listening for exceptions of type
+   EXC_BAD_ACCESS.  */
+static void *
+mach_exception_thread (void *arg)
+{
+  /* Buffer for a message to be received.  */
+  struct {
+    mach_msg_header_t head;
+    mach_msg_body_t msgh_body;
+    char data[1024];
+  } msg;
+  mach_msg_return_t retval;
+  /* Wait for a message on the exception port.  */
+  retval = mach_msg (&msg.head, MACH_RCV_MSG | MACH_RCV_LARGE, 0, sizeof (msg),
+                     our_exception_port, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
+  if (retval != MACH_MSG_SUCCESS)
+    abort ();
+  exit (1);
+}
+static void
+nocrash_init (void)
+{
+  mach_port_t self = mach_task_self ();
+  /* Allocate a port on which the thread shall listen for exceptions.  */
+  if (mach_port_allocate (self, MACH_PORT_RIGHT_RECEIVE, &our_exception_port)
+      == KERN_SUCCESS) {
+    /* See https://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_port_insert_right.html.  */
+    if (mach_port_insert_right (self, our_exception_port, our_exception_port,
+                                MACH_MSG_TYPE_MAKE_SEND)
+        == KERN_SUCCESS) {
+      /* The exceptions we want to catch.  Only EXC_BAD_ACCESS is interesting
+         for us.  */
+      exception_mask_t mask = EXC_MASK_BAD_ACCESS;
+      /* Create the thread listening on the exception port.  */
+      pthread_attr_t attr;
+      pthread_t thread;
+      if (pthread_attr_init (&attr) == 0
+          && pthread_attr_setdetachstate (&attr, PTHREAD_CREATE_DETACHED) == 0
+          && pthread_create (&thread, &attr, mach_exception_thread, NULL) == 0) {
+        pthread_attr_destroy (&attr);
+        /* Replace the exception port info for these exceptions with our own.
+           Note that we replace the exception port for the entire task, not only
+           for a particular thread.  This has the effect that when our exception
+           port gets the message, the thread specific exception port has already
+           been asked, and we don't need to bother about it.
+           See https://web.mit.edu/darwin/src/modules/xnu/osfmk/man/task_set_exception_ports.html.  */
+        task_set_exception_ports (self, mask, our_exception_port,
+                                  EXCEPTION_DEFAULT, MACHINE_THREAD_STATE);
+      }
+    }
+  }
+}
+#elif defined _WIN32 && ! defined __CYGWIN__
+/* Avoid a crash on native Windows.  */
+#define WIN32_LEAN_AND_MEAN
+#include <windows.h>
+#include <winerror.h>
+static LONG WINAPI
+exception_filter (EXCEPTION_POINTERS *ExceptionInfo)
+{
+  switch (ExceptionInfo->ExceptionRecord->ExceptionCode)
+    {
+    case EXCEPTION_ACCESS_VIOLATION:
+    case EXCEPTION_IN_PAGE_ERROR:
+    case EXCEPTION_STACK_OVERFLOW:
+    case EXCEPTION_GUARD_PAGE:
+    case EXCEPTION_PRIV_INSTRUCTION:
+    case EXCEPTION_ILLEGAL_INSTRUCTION:
+    case EXCEPTION_DATATYPE_MISALIGNMENT:
+    case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:
+    case EXCEPTION_NONCONTINUABLE_EXCEPTION:
+      exit (1);
+    }
+  return EXCEPTION_CONTINUE_SEARCH;
+}
+static void
+nocrash_init (void)
+{
+  SetUnhandledExceptionFilter ((LPTOP_LEVEL_EXCEPTION_FILTER) exception_filter);
+}
+#else
+/* Avoid a crash on POSIX systems.  */
+#include <signal.h>
+#include <unistd.h>
+/* A POSIX signal handler.  */
+static void
+exception_handler (int sig)
+{
+  _exit (1);
+}
+static void
+nocrash_init (void)
+{
+#ifdef SIGSEGV
+  signal (SIGSEGV, exception_handler);
+#endif
+#ifdef SIGBUS
+  signal (SIGBUS, exception_handler);
+#endif
+}
 #endif
-
-_ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "MicrosoftCompiler" >/dev/null 2>&1
-then :
-            rm -f conftest*
-     echo 'int dummy;' > conftest.c
-     { ac_try='${CC-cc} $CFLAGS $CPPFLAGS -c conftest.c'
-  { { eval echo "\"\$as_me\":${as_lineno-$LINENO}: \"$ac_try\""; } >&5
-  (eval $ac_try) 2>&5
-  ac_status=$?
-  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; } >/dev/null 2>&1
-     if test -f conftest.o; then
-       gl_asmext='s'
-       gl_c_asm_opt='-S'
-     else
-       gl_asmext='asm'
-       gl_c_asm_opt='-c -Fa'
-     fi
-     rm -f conftest*
-
-else $as_nop
-  gl_asmext='s'
-     gl_c_asm_opt='-S'
-
-fi
-rm -rf conftest*
-
-
 
 
+int
+main (void)
+{
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking host CPU and C ABI" >&5
-printf %s "checking host CPU and C ABI... " >&6; }
-if test ${gl_cv_host_cpu_c_abi+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  case "$host_cpu" in
+             int result = 0;
 
-       i[34567]86 )
-         gl_cv_host_cpu_c_abi=i386
-         ;;
+             nocrash_init();
 
-       x86_64 )
-         # On x86_64 systems, the C compiler may be generating code in one of
-         # these ABIs:
-         # - 64-bit instruction set, 64-bit pointers, 64-bit 'long': x86_64.
-         # - 64-bit instruction set, 64-bit pointers, 32-bit 'long': x86_64
-         #   with native Windows (mingw, MSVC).
-         # - 64-bit instruction set, 32-bit pointers, 32-bit 'long': x86_64-x32.
-         # - 32-bit instruction set, 32-bit pointers, 32-bit 'long': i386.
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#if (defined __x86_64__ || defined __amd64__ \
-                     || defined _M_X64 || defined _M_AMD64)
-                 int ok;
-                #else
-                 error fail
-                #endif
+             /* This code succeeds on glibc 2.8, OpenBSD 4.0, Cygwin, mingw,
+                and fails on Mac OS X 10.5, AIX 5.2, HP-UX 11, IRIX 6.5,
+                OSF/1 5.1, Solaris 10.  */
+             {
+               static char conftest[] = "conftest";
+               static char plus[] = "-+";
+               char *argv[3] = { conftest, plus, NULL };
+               opterr = 0;
+               if (getopt (2, argv, "+a") != '?')
+                 result |= 1;
+             }
+             /* This code succeeds on glibc 2.8, mingw,
+                and fails on Mac OS X 10.5, OpenBSD 4.0, AIX 5.2, HP-UX 11,
+                IRIX 6.5, OSF/1 5.1, Solaris 10, Cygwin 1.5.x.  */
+             {
+               static char program[] = "program";
+               static char p[] = "-p";
+               static char foo[] = "foo";
+               static char bar[] = "bar";
+               char *argv[] = { program, p, foo, bar, NULL };
 
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#if defined __ILP32__ || defined _ILP32
-                    int ok;
-                   #else
-                    error fail
-                   #endif
+               optind = 1;
+               if (getopt (4, argv, "p::") != 'p')
+                 result |= 2;
+               else if (optarg != NULL)
+                 result |= 4;
+               else if (getopt (4, argv, "p::") != -1)
+                 result |= 6;
+               else if (optind != 2)
+                 result |= 8;
+             }
+             /* This code succeeds on glibc 2.8 and fails on Cygwin 1.7.0.  */
+             {
+               static char program[] = "program";
+               static char foo[] = "foo";
+               static char p[] = "-p";
+               char *argv[] = { program, foo, p, NULL };
+               optind = 0;
+               if (getopt (3, argv, "-p") != 1)
+                 result |= 16;
+               else if (getopt (3, argv, "-p") != 'p')
+                 result |= 16;
+             }
+             /* This code fails on glibc 2.11.  */
+             {
+               static char program[] = "program";
+               static char b[] = "-b";
+               static char a[] = "-a";
+               char *argv[] = { program, b, a, NULL };
+               optind = opterr = 0;
+               if (getopt (3, argv, "+:a:b") != 'b')
+                 result |= 32;
+               else if (getopt (3, argv, "+:a:b") != ':')
+                 result |= 32;
+             }
+             /* This code dumps core on glibc 2.14.  */
+             {
+               static char program[] = "program";
+               static char w[] = "-W";
+               static char dummy[] = "dummy";
+               char *argv[] = { program, w, dummy, NULL };
+               optind = opterr = 1;
+               if (getopt (3, argv, "W;") != 'W')
+                 result |= 64;
+             }
+             return result;
 
+  ;
+  return 0;
+}
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi=x86_64-x32
+  gl_cv_func_getopt_gnu=yes
 else $as_nop
-  gl_cv_host_cpu_c_abi=x86_64
+  gl_cv_func_getopt_gnu=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-else $as_nop
-  gl_cv_host_cpu_c_abi=i386
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         ;;
-
-       alphaev[4-8] | alphaev56 | alphapca5[67] | alphaev6[78] )
-         gl_cv_host_cpu_c_abi=alpha
-         ;;
 
-       arm* | aarch64 )
-         # Assume arm with EABI.
-         # On arm64 systems, the C compiler may be generating code in one of
-         # these ABIs:
-         # - aarch64 instruction set, 64-bit pointers, 64-bit 'long': arm64.
-         # - aarch64 instruction set, 32-bit pointers, 32-bit 'long': arm64-ilp32.
-         # - 32-bit instruction set, 32-bit pointers, 32-bit 'long': arm or armhf.
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#ifdef __aarch64__
-                 int ok;
-                #else
-                 error fail
-                #endif
+       case $gl_had_POSIXLY_CORRECT in
+         exported) ;;
+         yes) { POSIXLY_CORRECT=; unset POSIXLY_CORRECT;}; POSIXLY_CORRECT=1 ;;
+         *) { POSIXLY_CORRECT=; unset POSIXLY_CORRECT;} ;;
+       esac
 
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_getopt_gnu" >&5
+printf "%s\n" "$gl_cv_func_getopt_gnu" >&6; }
+    if test "$gl_cv_func_getopt_gnu" != yes; then
+      gl_replace_getopt=yes
+    else
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working GNU getopt_long function" >&5
+printf %s "checking for working GNU getopt_long function... " >&6; }
+if test ${gl_cv_func_getopt_long_gnu+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
 then :
+              case "$host_os" in
+              openbsd*) gl_cv_func_getopt_long_gnu="guessing no";;
+              *)        gl_cv_func_getopt_long_gnu="guessing yes";;
+            esac
+
+else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined __ILP32__ || defined _ILP32
-                   int ok;
-                  #else
-                   error fail
-                  #endif
+#include <getopt.h>
+                #include <stddef.h>
+                #include <string.h>
+
+int
+main (void)
+{
+static const struct option long_options[] =
+                  {
+                    { "xtremely-",no_argument,       NULL, 1003 },
+                    { "xtra",     no_argument,       NULL, 1001 },
+                    { "xtreme",   no_argument,       NULL, 1002 },
+                    { "xtremely", no_argument,       NULL, 1003 },
+                    { NULL,       0,                 NULL, 0 }
+                  };
+                /* This code fails on OpenBSD 5.0.  */
+                {
+                  static char program[] = "program";
+                  static char xtremel[] = "--xtremel";
+                  char *argv[] = { program, xtremel, NULL };
+                  int option_index;
+                  optind = 1; opterr = 0;
+                  if (getopt_long (2, argv, "", long_options, &option_index) != 1003)
+                    return 1;
+                }
+                return 0;
 
+  ;
+  return 0;
+}
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi=arm64-ilp32
+  gl_cv_func_getopt_long_gnu=yes
 else $as_nop
-  gl_cv_host_cpu_c_abi=arm64
+  gl_cv_func_getopt_long_gnu=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-else $as_nop
-  # Don't distinguish little-endian and big-endian arm, since they
-            # don't require different machine code for simple operations and
-            # since the user can distinguish them through the preprocessor
-            # defines __ARMEL__ vs. __ARMEB__.
-            # But distinguish arm which passes floating-point arguments and
-            # return values in integer registers (r0, r1, ...) - this is
-            # gcc -mfloat-abi=soft or gcc -mfloat-abi=softfp - from arm which
-            # passes them in float registers (s0, s1, ...) and double registers
-            # (d0, d1, ...) - this is gcc -mfloat-abi=hard. GCC 4.6 or newer
-            # sets the preprocessor defines __ARM_PCS (for the first case) and
-            # __ARM_PCS_VFP (for the second case), but older GCC does not.
-            echo 'double ddd; void func (double dd) { ddd = dd; }' > conftest.c
-            # Look for a reference to the register d0 in the .s file.
-            { ac_try='${CC-cc} $CFLAGS $CPPFLAGS $gl_c_asm_opt conftest.c'
-  { { eval echo "\"\$as_me\":${as_lineno-$LINENO}: \"$ac_try\""; } >&5
-  (eval $ac_try) 2>&5
-  ac_status=$?
-  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; } >/dev/null 2>&1
-            if LC_ALL=C grep 'd0,' conftest.$gl_asmext >/dev/null; then
-              gl_cv_host_cpu_c_abi=armhf
-            else
-              gl_cv_host_cpu_c_abi=arm
-            fi
-            rm -f conftest*
+
 
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         ;;
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_getopt_long_gnu" >&5
+printf "%s\n" "$gl_cv_func_getopt_long_gnu" >&6; }
+      case "$gl_cv_func_getopt_long_gnu" in
+        *yes) ;;
+        *) gl_replace_getopt=yes ;;
+      esac
+    fi
+  fi
 
-       hppa1.0 | hppa1.1 | hppa2.0* | hppa64 )
-         # On hppa, the C compiler may be generating 32-bit code or 64-bit
-         # code. In the latter case, it defines _LP64 and __LP64__.
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#ifdef __LP64__
-                 int ok;
-                #else
-                 error fail
-                #endif
 
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
+
+
+
+    HAVE_GETRANDOM=1;
+  REPLACE_GETRANDOM=0;
+
+
+
+
+  GL_M4_GNULIB_GETRANDOM=0
+
+
+
+
+
+
+
+  if test -z "$gl_pthreadlib_body_done"; then
+    gl_pthread_api=no
+    LIBPTHREAD=
+    LIBPMULTITHREAD=
+    # On OSF/1, the compiler needs the flag -pthread or -D_REENTRANT so that
+    # it groks <pthread.h>. It's added above, in gl_ANYTHREADLIB_EARLY.
+    ac_fn_c_check_header_compile "$LINENO" "pthread.h" "ac_cv_header_pthread_h" "$ac_includes_default"
+if test "x$ac_cv_header_pthread_h" = xyes
 then :
-  gl_cv_host_cpu_c_abi=hppa64
+  gl_have_pthread_h=yes
 else $as_nop
-  gl_cv_host_cpu_c_abi=hppa
+  gl_have_pthread_h=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         ;;
 
-       ia64* )
-         # On ia64 on HP-UX, the C compiler may be generating 64-bit code or
-         # 32-bit code. In the latter case, it defines _ILP32.
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+    if test "$gl_have_pthread_h" = yes; then
+      # Other possible tests:
+      #   -lpthreads (FSU threads, PCthreads)
+      #   -lgthreads
+      # Test whether both pthread_mutex_lock and pthread_mutexattr_init exist
+      # in libc. IRIX 6.5 has the first one in both libc and libpthread, but
+      # the second one only in libpthread, and lock.c needs it.
+      #
+      # If -pthread works, prefer it to -lpthread, since Ubuntu 14.04
+      # needs -pthread for some reason.  See:
+      # https://lists.gnu.org/r/bug-gnulib/2014-09/msg00023.html
+      save_LIBS=$LIBS
+      for gl_pthread in '' '-pthread'; do
+        LIBS="$LIBS $gl_pthread"
+        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#ifdef _ILP32
-                 int ok;
-                #else
-                 error fail
-                #endif
+#include <pthread.h>
+               pthread_mutex_t m;
+               pthread_mutexattr_t ma;
 
+int
+main (void)
+{
+pthread_mutex_lock (&m);
+               pthread_mutexattr_init (&ma);
+  ;
+  return 0;
+}
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if ac_fn_c_try_link "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi=ia64-ilp32
-else $as_nop
-  gl_cv_host_cpu_c_abi=ia64
+  gl_pthread_api=yes
+           LIBPTHREAD=$gl_pthread
+           LIBPMULTITHREAD=$gl_pthread
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         ;;
-
-       mips* )
-         # We should also check for (_MIPS_SZPTR == 64), but gcc keeps this
-         # at 32.
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#if defined _MIPS_SZLONG && (_MIPS_SZLONG == 64)
-                 int ok;
-                #else
-                 error fail
-                #endif
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+        LIBS=$save_LIBS
+        test $gl_pthread_api = yes && break
+      done
 
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
+      # Test for libpthread by looking for pthread_kill. (Not pthread_self,
+      # since it is defined as a macro on OSF/1.)
+      if test $gl_pthread_api = yes && test -z "$LIBPTHREAD"; then
+        # The program links fine without libpthread. But it may actually
+        # need to link with libpthread in order to create multiple threads.
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for pthread_kill in -lpthread" >&5
+printf %s "checking for pthread_kill in -lpthread... " >&6; }
+if test ${ac_cv_lib_pthread_pthread_kill+y}
 then :
-  gl_cv_host_cpu_c_abi=mips64
+  printf %s "(cached) " >&6
 else $as_nop
-  # In the n32 ABI, _ABIN32 is defined, _ABIO32 is not defined (but
-            # may later get defined by <sgidefs.h>), and _MIPS_SIM == _ABIN32.
-            # In the 32 ABI, _ABIO32 is defined, _ABIN32 is not defined (but
-            # may later get defined by <sgidefs.h>), and _MIPS_SIM == _ABIO32.
-            cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lpthread  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if (_MIPS_SIM == _ABIN32)
-                    int ok;
-                   #else
-                    error fail
-                   #endif
 
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+char pthread_kill ();
+int
+main (void)
+{
+return pthread_kill ();
+  ;
+  return 0;
+}
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if ac_fn_c_try_link "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi=mipsn32
+  ac_cv_lib_pthread_pthread_kill=yes
 else $as_nop
-  gl_cv_host_cpu_c_abi=mips
+  ac_cv_lib_pthread_pthread_kill=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         ;;
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_pthread_pthread_kill" >&5
+printf "%s\n" "$ac_cv_lib_pthread_pthread_kill" >&6; }
+if test "x$ac_cv_lib_pthread_pthread_kill" = xyes
+then :
+  LIBPMULTITHREAD=-lpthread
+           # On Solaris and HP-UX, most pthread functions exist also in libc.
+           # Therefore pthread_in_use() needs to actually try to create a
+           # thread: pthread_create from libc will fail, whereas
+           # pthread_create will actually create a thread.
+           # On Solaris 10 or newer, this test is no longer needed, because
+           # libc contains the fully functional pthread functions.
+           case "$host_os" in
+             solaris | solaris2.1-9 | solaris2.1-9.* | hpux*)
 
-       powerpc* )
-         # Different ABIs are in use on AIX vs. Mac OS X vs. Linux,*BSD.
-         # No need to distinguish them here; the caller may distinguish
-         # them based on the OS.
-         # On powerpc64 systems, the C compiler may still be generating
-         # 32-bit code. And on powerpc-ibm-aix systems, the C compiler may
-         # be generating 64-bit code.
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#if defined __powerpc64__ || defined __LP64__
-                 int ok;
-                #else
-                 error fail
-                #endif
+printf "%s\n" "#define PTHREAD_IN_USE_DETECTION_HARD 1" >>confdefs.h
 
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
+           esac
+
+fi
+
+      elif test $gl_pthread_api != yes; then
+        # Some library is needed. Try libpthread and libc_r.
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for pthread_kill in -lpthread" >&5
+printf %s "checking for pthread_kill in -lpthread... " >&6; }
+if test ${ac_cv_lib_pthread_pthread_kill+y}
 then :
-  # On powerpc64, there are two ABIs on Linux: The AIX compatible
-            # one and the ELFv2 one. The latter defines _CALL_ELF=2.
-            cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  printf %s "(cached) " >&6
+else $as_nop
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lpthread  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined _CALL_ELF && _CALL_ELF == 2
-                    int ok;
-                   #else
-                    error fail
-                   #endif
 
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+char pthread_kill ();
+int
+main (void)
+{
+return pthread_kill ();
+  ;
+  return 0;
+}
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if ac_fn_c_try_link "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi=powerpc64-elfv2
+  ac_cv_lib_pthread_pthread_kill=yes
 else $as_nop
-  gl_cv_host_cpu_c_abi=powerpc64
+  ac_cv_lib_pthread_pthread_kill=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-
-else $as_nop
-  gl_cv_host_cpu_c_abi=powerpc
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_pthread_pthread_kill" >&5
+printf "%s\n" "$ac_cv_lib_pthread_pthread_kill" >&6; }
+if test "x$ac_cv_lib_pthread_pthread_kill" = xyes
+then :
+  gl_pthread_api=yes
+           LIBPTHREAD=-lpthread
+           LIBPMULTITHREAD=-lpthread
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         ;;
-
-       rs6000 )
-         gl_cv_host_cpu_c_abi=powerpc
-         ;;
-
-       riscv32 | riscv64 )
-         # There are 2 architectures (with variants): rv32* and rv64*.
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#if __riscv_xlen == 64
-                  int ok;
-                #else
-                  error fail
-                #endif
 
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
+        if test $gl_pthread_api != yes; then
+          # For FreeBSD 4.
+          { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for pthread_kill in -lc_r" >&5
+printf %s "checking for pthread_kill in -lc_r... " >&6; }
+if test ${ac_cv_lib_c_r_pthread_kill+y}
 then :
-  cpu=riscv64
+  printf %s "(cached) " >&6
 else $as_nop
-  cpu=riscv32
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         # There are 6 ABIs: ilp32, ilp32f, ilp32d, lp64, lp64f, lp64d.
-         # Size of 'long' and 'void *':
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lc_r  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined __LP64__
-                  int ok;
-                #else
-                  error fail
-                #endif
 
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+char pthread_kill ();
+int
+main (void)
+{
+return pthread_kill ();
+  ;
+  return 0;
+}
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if ac_fn_c_try_link "$LINENO"
 then :
-  main_abi=lp64
+  ac_cv_lib_c_r_pthread_kill=yes
 else $as_nop
-  main_abi=ilp32
+  ac_cv_lib_c_r_pthread_kill=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         # Float ABIs:
-         # __riscv_float_abi_double:
-         #   'float' and 'double' are passed in floating-point registers.
-         # __riscv_float_abi_single:
-         #   'float' are passed in floating-point registers.
-         # __riscv_float_abi_soft:
-         #   No values are passed in floating-point registers.
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#if defined __riscv_float_abi_double
-                  int ok;
-                #else
-                  error fail
-                #endif
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_c_r_pthread_kill" >&5
+printf "%s\n" "$ac_cv_lib_c_r_pthread_kill" >&6; }
+if test "x$ac_cv_lib_c_r_pthread_kill" = xyes
+then :
+  gl_pthread_api=yes
+             LIBPTHREAD=-lc_r
+             LIBPMULTITHREAD=-lc_r
+fi
+
+        fi
+      fi
+    fi
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether POSIX threads API is available" >&5
+printf %s "checking whether POSIX threads API is available... " >&6; }
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_pthread_api" >&5
+printf "%s\n" "$gl_pthread_api" >&6; }
+
+
+    if test $gl_pthread_api = yes; then
+
+printf "%s\n" "#define HAVE_PTHREAD_API 1" >>confdefs.h
+
+    fi
 
+        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <sched.h>
+int
+main (void)
+{
+sched_yield ();
+  ;
+  return 0;
+}
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if ac_fn_c_try_link "$LINENO"
 then :
-  float_abi=d
+  LIB_SCHED_YIELD=
+
 else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for sched_yield in -lrt" >&5
+printf %s "checking for sched_yield in -lrt... " >&6; }
+if test ${ac_cv_lib_rt_sched_yield+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lrt  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined __riscv_float_abi_single
-                     int ok;
-                   #else
-                     error fail
-                   #endif
 
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+char sched_yield ();
+int
+main (void)
+{
+return sched_yield ();
+  ;
+  return 0;
+}
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if ac_fn_c_try_link "$LINENO"
 then :
-  float_abi=f
+  ac_cv_lib_rt_sched_yield=yes
 else $as_nop
-  float_abi=''
+  ac_cv_lib_rt_sched_yield=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         gl_cv_host_cpu_c_abi="${cpu}-${main_abi}${float_abi}"
-         ;;
-
-       s390* )
-         # On s390x, the C compiler may be generating 64-bit (= s390x) code
-         # or 31-bit (= s390) code.
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#if defined __LP64__ || defined __s390x__
-                  int ok;
-                #else
-                  error fail
-                #endif
-
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_rt_sched_yield" >&5
+printf "%s\n" "$ac_cv_lib_rt_sched_yield" >&6; }
+if test "x$ac_cv_lib_rt_sched_yield" = xyes
 then :
-  gl_cv_host_cpu_c_abi=s390x
+  LIB_SCHED_YIELD=-lrt
 else $as_nop
-  gl_cv_host_cpu_c_abi=s390
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         ;;
-
-       sparc | sparc64 )
-         # UltraSPARCs running Linux have `uname -m` = "sparc64", but the
-         # C compiler still generates 32-bit code.
-         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for sched_yield in -lposix4" >&5
+printf %s "checking for sched_yield in -lposix4... " >&6; }
+if test ${ac_cv_lib_posix4_sched_yield+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lposix4  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined __sparcv9 || defined __arch64__
-                 int ok;
-                #else
-                 error fail
-                #endif
 
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+char sched_yield ();
+int
+main (void)
+{
+return sched_yield ();
+  ;
+  return 0;
+}
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if ac_fn_c_try_link "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi=sparc64
+  ac_cv_lib_posix4_sched_yield=yes
 else $as_nop
-  gl_cv_host_cpu_c_abi=sparc
+  ac_cv_lib_posix4_sched_yield=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_posix4_sched_yield" >&5
+printf "%s\n" "$ac_cv_lib_posix4_sched_yield" >&6; }
+if test "x$ac_cv_lib_posix4_sched_yield" = xyes
+then :
+  LIB_SCHED_YIELD=-lposix4
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-         ;;
-
-       *)
-         gl_cv_host_cpu_c_abi="$host_cpu"
-         ;;
-     esac
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_host_cpu_c_abi" >&5
-printf "%s\n" "$gl_cv_host_cpu_c_abi" >&6; }
 
-    HOST_CPU=`echo "$gl_cv_host_cpu_c_abi" | sed -e 's/-.*//'`
-  HOST_CPU_C_ABI="$gl_cv_host_cpu_c_abi"
 
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
 
 
-  # This was
-  #   AC_DEFINE_UNQUOTED([__${HOST_CPU}__])
-  #   AC_DEFINE_UNQUOTED([__${HOST_CPU_C_ABI}__])
-  # earlier, but KAI C++ 3.2d doesn't like this.
-  sed -e 's/-/_/g' >> confdefs.h <<EOF
-#ifndef __${HOST_CPU}__
-#define __${HOST_CPU}__ 1
-#endif
-#ifndef __${HOST_CPU_C_ABI}__
-#define __${HOST_CPU_C_ABI}__ 1
-#endif
-EOF
+    gl_pthreadlib_body_done=done
+  fi
 
 
 
 
-      if test "X$prefix" = "XNONE"; then
-    acl_final_prefix="$ac_default_prefix"
-  else
-    acl_final_prefix="$prefix"
-  fi
-  if test "X$exec_prefix" = "XNONE"; then
-    acl_final_exec_prefix='${prefix}'
-  else
-    acl_final_exec_prefix="$exec_prefix"
-  fi
-  acl_save_prefix="$prefix"
-  prefix="$acl_final_prefix"
-  eval acl_final_exec_prefix=\"$acl_final_exec_prefix\"
-  prefix="$acl_save_prefix"
 
 
 
-# Check whether --with-gnu-ld was given.
-if test ${with_gnu_ld+y}
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether setlocale (LC_ALL, NULL) is multithread-safe" >&5
+printf %s "checking whether setlocale (LC_ALL, NULL) is multithread-safe... " >&6; }
+if test ${gl_cv_func_setlocale_null_all_mtsafe+y}
 then :
-  withval=$with_gnu_ld; test "$withval" = no || with_gnu_ld=yes
+  printf %s "(cached) " >&6
 else $as_nop
-  with_gnu_ld=no
-fi
+  case "$host_os" in
+       # Guess no on musl libc, macOS, FreeBSD, NetBSD, OpenBSD, AIX, Haiku, Cygwin.
+       *-musl* | darwin* | freebsd* | midnightbsd* | netbsd* | openbsd* | aix* | haiku* | cygwin*)
+         gl_cv_func_setlocale_null_all_mtsafe=no ;;
+       # Guess yes on glibc, HP-UX, IRIX, Solaris, native Windows.
+       *-gnu* | gnu* | hpux* | irix* | solaris* | mingw*)
+         gl_cv_func_setlocale_null_all_mtsafe=yes ;;
+       # If we don't know, obey --enable-cross-guesses.
+       *)
+         gl_cv_func_setlocale_null_all_mtsafe="$gl_cross_guess_normal" ;;
+     esac
 
-# Prepare PATH_SEPARATOR.
-# The user is always right.
-if test "${PATH_SEPARATOR+set}" != set; then
-  # Determine PATH_SEPARATOR by trying to find /bin/sh in a PATH which
-  # contains only /bin. Note that ksh looks also at the FPATH variable,
-  # so we have to set that as well for the test.
-  PATH_SEPARATOR=:
-  (PATH='/bin;/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 \
-    && { (PATH='/bin:/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 \
-           || PATH_SEPARATOR=';'
-       }
 fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_setlocale_null_all_mtsafe" >&5
+printf "%s\n" "$gl_cv_func_setlocale_null_all_mtsafe" >&6; }
+    case "$host_os" in
+    mingw*) ;;
+    *)
+      if test $gl_pthread_api = no && test $ac_cv_header_threads_h = no; then
+        gl_cv_func_setlocale_null_all_mtsafe="trivially yes"
+      fi
+      ;;
+  esac
+  case "$gl_cv_func_setlocale_null_all_mtsafe" in
+    *yes) SETLOCALE_NULL_ALL_MTSAFE=1 ;;
+    *)    SETLOCALE_NULL_ALL_MTSAFE=0 ;;
+  esac
 
-if test -n "$LD"; then
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for ld" >&5
-printf %s "checking for ld... " >&6; }
-elif test "$GCC" = yes; then
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for ld used by $CC" >&5
-printf %s "checking for ld used by $CC... " >&6; }
-elif test "$with_gnu_ld" = yes; then
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for GNU ld" >&5
-printf %s "checking for GNU ld... " >&6; }
-else
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for non-GNU ld" >&5
-printf %s "checking for non-GNU ld... " >&6; }
-fi
-if test -n "$LD"; then
-  # Let the user override the test with a path.
-  :
-else
-  if test ${acl_cv_path_LD+y}
+printf "%s\n" "#define SETLOCALE_NULL_ALL_MTSAFE $SETLOCALE_NULL_ALL_MTSAFE" >>confdefs.h
+
+
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether setlocale (category, NULL) is multithread-safe" >&5
+printf %s "checking whether setlocale (category, NULL) is multithread-safe... " >&6; }
+if test ${gl_cv_func_setlocale_null_one_mtsafe+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
+  case "$host_os" in
+       # Guess no on OpenBSD, AIX.
+       openbsd* | aix*)
+         gl_cv_func_setlocale_null_one_mtsafe=no ;;
+       # Guess yes on glibc, musl libc, macOS, FreeBSD, NetBSD, HP-UX, IRIX, Solaris, Haiku, Cygwin, native Windows.
+       *-gnu* | gnu* | *-musl* | darwin* | freebsd* | midnightbsd* | netbsd* | hpux* | irix* | solaris* | haiku* | cygwin* | mingw*)
+         gl_cv_func_setlocale_null_one_mtsafe=yes ;;
+       # If we don't know, obey --enable-cross-guesses.
+       *)
+         gl_cv_func_setlocale_null_one_mtsafe="$gl_cross_guess_normal" ;;
+     esac
 
-    acl_cv_path_LD= # Final result of this test
-    ac_prog=ld # Program to search in $PATH
-    if test "$GCC" = yes; then
-      # Check if gcc -print-prog-name=ld gives a path.
-      case $host in
-        *-*-mingw*)
-          # gcc leaves a trailing carriage return which upsets mingw
-          acl_output=`($CC -print-prog-name=ld) 2>&5 | tr -d '\015'` ;;
-        *)
-          acl_output=`($CC -print-prog-name=ld) 2>&5` ;;
-      esac
-      case $acl_output in
-        # Accept absolute paths.
-        [\\/]* | ?:[\\/]*)
-          re_direlt='/[^/][^/]*/\.\./'
-          # Canonicalize the pathname of ld
-          acl_output=`echo "$acl_output" | sed 's%\\\\%/%g'`
-          while echo "$acl_output" | grep "$re_direlt" > /dev/null 2>&1; do
-            acl_output=`echo $acl_output | sed "s%$re_direlt%/%"`
-          done
-          # Got the pathname. No search in PATH is needed.
-          acl_cv_path_LD="$acl_output"
-          ac_prog=
-          ;;
-        "")
-          # If it fails, then pretend we aren't using GCC.
-          ;;
-        *)
-          # If it is relative, then search for the first ld in PATH.
-          with_gnu_ld=unknown
-          ;;
-      esac
-    fi
-    if test -n "$ac_prog"; then
-      # Search for $ac_prog in $PATH.
-      acl_save_ifs="$IFS"; IFS=$PATH_SEPARATOR
-      for ac_dir in $PATH; do
-        IFS="$acl_save_ifs"
-        test -z "$ac_dir" && ac_dir=.
-        if test -f "$ac_dir/$ac_prog" || test -f "$ac_dir/$ac_prog$ac_exeext"; then
-          acl_cv_path_LD="$ac_dir/$ac_prog"
-          # Check to see if the program is GNU ld.  I'd rather use --version,
-          # but apparently some variants of GNU ld only accept -v.
-          # Break only if it was the GNU/non-GNU ld that we prefer.
-          case `"$acl_cv_path_LD" -v 2>&1 </dev/null` in
-            *GNU* | *'with BFD'*)
-              test "$with_gnu_ld" != no && break
-              ;;
-            *)
-              test "$with_gnu_ld" != yes && break
-              ;;
-          esac
-        fi
-      done
-      IFS="$acl_save_ifs"
-    fi
-    case $host in
-      *-*-aix*)
-        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#if defined __powerpc64__ || defined __LP64__
-                int ok;
-               #else
-                error fail
-               #endif
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_setlocale_null_one_mtsafe" >&5
+printf "%s\n" "$gl_cv_func_setlocale_null_one_mtsafe" >&6; }
+    case "$host_os" in
+    mingw*) ;;
+    *)
+      if test $gl_pthread_api = no && test $ac_cv_header_threads_h = no; then
+        gl_cv_func_setlocale_null_one_mtsafe="trivially yes"
+      fi
+      ;;
+  esac
+  case "$gl_cv_func_setlocale_null_one_mtsafe" in
+    *yes) SETLOCALE_NULL_ONE_MTSAFE=1 ;;
+    *)    SETLOCALE_NULL_ONE_MTSAFE=0 ;;
+  esac
+
+printf "%s\n" "#define SETLOCALE_NULL_ONE_MTSAFE $SETLOCALE_NULL_ONE_MTSAFE" >>confdefs.h
+
+
+    if test $SETLOCALE_NULL_ALL_MTSAFE = 0 || test $SETLOCALE_NULL_ONE_MTSAFE = 0; then
+    case "$host_os" in
+      mingw*) LIB_SETLOCALE_NULL= ;;
+      *)
 
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether imported symbols can be declared weak" >&5
+printf %s "checking whether imported symbols can be declared weak... " >&6; }
+if test ${gl_cv_have_weak+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  gl_cv_have_weak=no
+          cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+extern void xyzzy ();
+#pragma weak xyzzy
+int
+main (void)
+{
+xyzzy();
+  ;
+  return 0;
+}
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if ac_fn_c_try_link "$LINENO"
 then :
-  # The compiler produces 64-bit code. Add option '-b64' so that the
-           # linker groks 64-bit object files.
-           case "$acl_cv_path_LD " in
-             *" -b64 "*) ;;
-             *) acl_cv_path_LD="$acl_cv_path_LD -b64" ;;
-           esac
-
+  gl_cv_have_weak=maybe
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-        ;;
-      sparc64-*-netbsd*)
-        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+     if test $gl_cv_have_weak = maybe; then
+                     if test "$cross_compiling" = yes
+then :
+                      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined __sparcv9 || defined __arch64__
-                int ok;
-               #else
-                error fail
-               #endif
+#ifdef __ELF__
+             Extensible Linking Format
+             #endif
 
 _ACEOF
-if ac_fn_c_try_compile "$LINENO"
+if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
+  $EGREP "Extensible Linking Format" >/dev/null 2>&1
 then :
-
+  gl_cv_have_weak="guessing yes"
 else $as_nop
-  # The compiler produces 32-bit code. Add option '-m elf32_sparc'
-           # so that the linker groks 32-bit object files.
-           case "$acl_cv_path_LD " in
-             *" -m elf32_sparc "*) ;;
-             *) acl_cv_path_LD="$acl_cv_path_LD -m elf32_sparc" ;;
-           esac
-
+  gl_cv_have_weak="guessing no"
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-        ;;
-    esac
+rm -rf conftest*
 
-fi
 
-  LD="$acl_cv_path_LD"
-fi
-if test -n "$LD"; then
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LD" >&5
-printf "%s\n" "$LD" >&6; }
-else
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
-printf "%s\n" "no" >&6; }
-  as_fn_error $? "no acceptable ld found in \$PATH" "$LINENO" 5
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking if the linker ($LD) is GNU ld" >&5
-printf %s "checking if the linker ($LD) is GNU ld... " >&6; }
-if test ${acl_cv_prog_gnu_ld+y}
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+#include <stdio.h>
+#pragma weak fputs
+int main ()
+{
+  return (fputs == NULL);
+}
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
 then :
-  printf %s "(cached) " >&6
+  gl_cv_have_weak=yes
 else $as_nop
-  # I'd rather use --version here, but apparently some GNU lds only accept -v.
-case `$LD -v 2>&1 </dev/null` in
-*GNU* | *'with BFD'*)
-  acl_cv_prog_gnu_ld=yes
-  ;;
-*)
-  acl_cv_prog_gnu_ld=no
-  ;;
-esac
+  gl_cv_have_weak=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $acl_cv_prog_gnu_ld" >&5
-printf "%s\n" "$acl_cv_prog_gnu_ld" >&6; }
-with_gnu_ld=$acl_cv_prog_gnu_ld
 
+     fi
+          case " $LDFLAGS " in
+       *" -static "*) gl_cv_have_weak=no ;;
+     esac
+                    case "$gl_cv_have_weak" in
+       *yes)
+         case "$host_os" in
+           freebsd* | dragonfly* | midnightbsd*)
+             : > conftest1.c
+             $CC $CPPFLAGS $CFLAGS $LDFLAGS -fPIC -shared -o libempty.so conftest1.c -lpthread >&5 2>&1
+             cat <<EOF > conftest2.c
+#include <pthread.h>
+#pragma weak pthread_mutexattr_gettype
+int main ()
+{
+  return (pthread_mutexattr_gettype != NULL);
+}
+EOF
+             $CC $CPPFLAGS $CFLAGS $LDFLAGS -o conftest conftest2.c libempty.so >&5 2>&1 \
+               || gl_cv_have_weak=no
+             rm -f conftest1.c libempty.so conftest2.c conftest
+             ;;
+         esac
+         ;;
+     esac
 
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_have_weak" >&5
+printf "%s\n" "$gl_cv_have_weak" >&6; }
+  case "$gl_cv_have_weak" in
+    *yes)
 
+printf "%s\n" "#define HAVE_WEAK_SYMBOLS 1" >>confdefs.h
 
+      ;;
+  esac
 
-                                                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for shared library run path origin" >&5
-printf %s "checking for shared library run path origin... " >&6; }
-if test ${acl_cv_rpath+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
+        case "$gl_cv_have_weak" in
+          *yes) LIB_SETLOCALE_NULL= ;;
+          *)    LIB_SETLOCALE_NULL="$LIBPTHREAD" ;;
+        esac
+        ;;
+    esac
+  else
+    LIB_SETLOCALE_NULL=
+  fi
 
-    CC="$CC" GCC="$GCC" LDFLAGS="$LDFLAGS" LD="$LD" with_gnu_ld="$with_gnu_ld" \
-    ${CONFIG_SHELL-/bin/sh} "$ac_aux_dir/config.rpath" "$host" > conftest.sh
-    . ./conftest.sh
-    rm -f ./conftest.sh
-    acl_cv_rpath=done
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $acl_cv_rpath" >&5
-printf "%s\n" "$acl_cv_rpath" >&6; }
-  wl="$acl_cv_wl"
-  acl_libext="$acl_cv_libext"
-  acl_shlibext="$acl_cv_shlibext"
-  acl_libname_spec="$acl_cv_libname_spec"
-  acl_library_names_spec="$acl_cv_library_names_spec"
-  acl_hardcode_libdir_flag_spec="$acl_cv_hardcode_libdir_flag_spec"
-  acl_hardcode_libdir_separator="$acl_cv_hardcode_libdir_separator"
-  acl_hardcode_direct="$acl_cv_hardcode_direct"
-  acl_hardcode_minus_L="$acl_cv_hardcode_minus_L"
-    # Check whether --enable-rpath was given.
-if test ${enable_rpath+y}
+
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+#ifdef _MSC_VER
+MicrosoftCompiler
+#endif
+
+_ACEOF
+if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
+  $EGREP "MicrosoftCompiler" >/dev/null 2>&1
 then :
-  enableval=$enable_rpath; :
+            rm -f conftest*
+     echo 'int dummy;' > conftest.c
+     { ac_try='${CC-cc} $CFLAGS $CPPFLAGS -c conftest.c'
+  { { eval echo "\"\$as_me\":${as_lineno-$LINENO}: \"$ac_try\""; } >&5
+  (eval $ac_try) 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; } >/dev/null 2>&1
+     if test -f conftest.o; then
+       gl_asmext='s'
+       gl_c_asm_opt='-S'
+     else
+       gl_asmext='asm'
+       gl_c_asm_opt='-c -Fa'
+     fi
+     rm -f conftest*
+
 else $as_nop
-  enable_rpath=yes
+  gl_asmext='s'
+     gl_c_asm_opt='-S'
+
 fi
+rm -rf conftest*
 
 
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking 32-bit host C ABI" >&5
-printf %s "checking 32-bit host C ABI... " >&6; }
-if test ${gl_cv_host_cpu_c_abi_32bit+y}
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking host CPU and C ABI" >&5
+printf %s "checking host CPU and C ABI... " >&6; }
+if test ${gl_cv_host_cpu_c_abi+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  if test -n "$gl_cv_host_cpu_c_abi"; then
-       case "$gl_cv_host_cpu_c_abi" in
-         i386 | x86_64-x32 | arm | armhf | arm64-ilp32 | hppa | ia64-ilp32 | mips | mipsn32 | powerpc | riscv*-ilp32* | s390 | sparc)
-           gl_cv_host_cpu_c_abi_32bit=yes ;;
-         x86_64 | alpha | arm64 | hppa64 | ia64 | mips64 | powerpc64 | powerpc64-elfv2 | riscv*-lp64* | s390x | sparc64 )
-           gl_cv_host_cpu_c_abi_32bit=no ;;
-         *)
-           gl_cv_host_cpu_c_abi_32bit=unknown ;;
-       esac
-     else
-       case "$host_cpu" in
-
-         # CPUs that only support a 32-bit ABI.
-         arc \
-         | bfin \
-         | cris* \
-         | csky \
-         | epiphany \
-         | ft32 \
-         | h8300 \
-         | m68k \
-         | microblaze | microblazeel \
-         | nds32 | nds32le | nds32be \
-         | nios2 | nios2eb | nios2el \
-         | or1k* \
-         | or32 \
-         | sh | sh1234 | sh1234elb \
-         | tic6x \
-         | xtensa* )
-           gl_cv_host_cpu_c_abi_32bit=yes
-           ;;
-
-         # CPUs that only support a 64-bit ABI.
-         alpha | alphaev[4-8] | alphaev56 | alphapca5[67] | alphaev6[78] \
-         | mmix )
-           gl_cv_host_cpu_c_abi_32bit=no
-           ;;
+  case "$host_cpu" in
 
-         i[34567]86 )
-           gl_cv_host_cpu_c_abi_32bit=yes
-           ;;
+       i[34567]86 )
+         gl_cv_host_cpu_c_abi=i386
+         ;;
 
-         x86_64 )
-           # On x86_64 systems, the C compiler may be generating code in one of
-           # these ABIs:
-           # - 64-bit instruction set, 64-bit pointers, 64-bit 'long': x86_64.
-           # - 64-bit instruction set, 64-bit pointers, 32-bit 'long': x86_64
-           #   with native Windows (mingw, MSVC).
-           # - 64-bit instruction set, 32-bit pointers, 32-bit 'long': x86_64-x32.
-           # - 32-bit instruction set, 32-bit pointers, 32-bit 'long': i386.
-           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+       x86_64 )
+         # On x86_64 systems, the C compiler may be generating code in one of
+         # these ABIs:
+         # - 64-bit instruction set, 64-bit pointers, 64-bit 'long': x86_64.
+         # - 64-bit instruction set, 64-bit pointers, 32-bit 'long': x86_64
+         #   with native Windows (mingw, MSVC).
+         # - 64-bit instruction set, 32-bit pointers, 32-bit 'long': x86_64-x32.
+         # - 32-bit instruction set, 32-bit pointers, 32-bit 'long': i386.
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if (defined __x86_64__ || defined __amd64__ \
+                     || defined _M_X64 || defined _M_AMD64)
+                 int ok;
+                #else
+                 error fail
+                #endif
+
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if (defined __x86_64__ || defined __amd64__ \
-                       || defined _M_X64 || defined _M_AMD64) \
-                      && !(defined __ILP32__ || defined _ILP32)
-                   int ok;
-                  #else
-                   error fail
-                  #endif
+#if defined __ILP32__ || defined _ILP32
+                    int ok;
+                   #else
+                    error fail
+                   #endif
 
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi_32bit=no
+  gl_cv_host_cpu_c_abi=x86_64-x32
 else $as_nop
-  gl_cv_host_cpu_c_abi_32bit=yes
+  gl_cv_host_cpu_c_abi=x86_64
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-           ;;
+else $as_nop
+  gl_cv_host_cpu_c_abi=i386
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+         ;;
 
-         arm* | aarch64 )
-           # Assume arm with EABI.
-           # On arm64 systems, the C compiler may be generating code in one of
-           # these ABIs:
-           # - aarch64 instruction set, 64-bit pointers, 64-bit 'long': arm64.
-           # - aarch64 instruction set, 32-bit pointers, 32-bit 'long': arm64-ilp32.
-           # - 32-bit instruction set, 32-bit pointers, 32-bit 'long': arm or armhf.
-           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+       alphaev[4-8] | alphaev56 | alphapca5[67] | alphaev6[78] )
+         gl_cv_host_cpu_c_abi=alpha
+         ;;
+
+       arm* | aarch64 )
+         # Assume arm with EABI.
+         # On arm64 systems, the C compiler may be generating code in one of
+         # these ABIs:
+         # - aarch64 instruction set, 64-bit pointers, 64-bit 'long': arm64.
+         # - aarch64 instruction set, 32-bit pointers, 32-bit 'long': arm64-ilp32.
+         # - 32-bit instruction set, 32-bit pointers, 32-bit 'long': arm or armhf.
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined __aarch64__ && !(defined __ILP32__ || defined _ILP32)
+#ifdef __aarch64__
+                 int ok;
+                #else
+                 error fail
+                #endif
+
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __ILP32__ || defined _ILP32
                    int ok;
                   #else
                    error fail
@@ -17013,334 +17644,319 @@
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi_32bit=no
+  gl_cv_host_cpu_c_abi=arm64-ilp32
 else $as_nop
-  gl_cv_host_cpu_c_abi_32bit=yes
+  gl_cv_host_cpu_c_abi=arm64
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-           ;;
+else $as_nop
+  # Don't distinguish little-endian and big-endian arm, since they
+            # don't require different machine code for simple operations and
+            # since the user can distinguish them through the preprocessor
+            # defines __ARMEL__ vs. __ARMEB__.
+            # But distinguish arm which passes floating-point arguments and
+            # return values in integer registers (r0, r1, ...) - this is
+            # gcc -mfloat-abi=soft or gcc -mfloat-abi=softfp - from arm which
+            # passes them in float registers (s0, s1, ...) and double registers
+            # (d0, d1, ...) - this is gcc -mfloat-abi=hard. GCC 4.6 or newer
+            # sets the preprocessor defines __ARM_PCS (for the first case) and
+            # __ARM_PCS_VFP (for the second case), but older GCC does not.
+            echo 'double ddd; void func (double dd) { ddd = dd; }' > conftest.c
+            # Look for a reference to the register d0 in the .s file.
+            { ac_try='${CC-cc} $CFLAGS $CPPFLAGS $gl_c_asm_opt conftest.c'
+  { { eval echo "\"\$as_me\":${as_lineno-$LINENO}: \"$ac_try\""; } >&5
+  (eval $ac_try) 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; } >/dev/null 2>&1
+            if LC_ALL=C grep 'd0,' conftest.$gl_asmext >/dev/null; then
+              gl_cv_host_cpu_c_abi=armhf
+            else
+              gl_cv_host_cpu_c_abi=arm
+            fi
+            rm -f conftest*
 
-         hppa1.0 | hppa1.1 | hppa2.0* | hppa64 )
-           # On hppa, the C compiler may be generating 32-bit code or 64-bit
-           # code. In the latter case, it defines _LP64 and __LP64__.
-           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+         ;;
+
+       hppa1.0 | hppa1.1 | hppa2.0* | hppa64 )
+         # On hppa, the C compiler may be generating 32-bit code or 64-bit
+         # code. In the latter case, it defines _LP64 and __LP64__.
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #ifdef __LP64__
-                   int ok;
-                  #else
-                   error fail
-                  #endif
+                 int ok;
+                #else
+                 error fail
+                #endif
 
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi_32bit=no
+  gl_cv_host_cpu_c_abi=hppa64
 else $as_nop
-  gl_cv_host_cpu_c_abi_32bit=yes
+  gl_cv_host_cpu_c_abi=hppa
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-           ;;
+         ;;
 
-         ia64* )
-           # On ia64 on HP-UX, the C compiler may be generating 64-bit code or
-           # 32-bit code. In the latter case, it defines _ILP32.
-           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+       ia64* )
+         # On ia64 on HP-UX, the C compiler may be generating 64-bit code or
+         # 32-bit code. In the latter case, it defines _ILP32.
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #ifdef _ILP32
-                   int ok;
-                  #else
-                   error fail
-                  #endif
+                 int ok;
+                #else
+                 error fail
+                #endif
 
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi_32bit=yes
+  gl_cv_host_cpu_c_abi=ia64-ilp32
 else $as_nop
-  gl_cv_host_cpu_c_abi_32bit=no
+  gl_cv_host_cpu_c_abi=ia64
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-           ;;
+         ;;
 
-         mips* )
-           # We should also check for (_MIPS_SZPTR == 64), but gcc keeps this
-           # at 32.
-           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+       mips* )
+         # We should also check for (_MIPS_SZPTR == 64), but gcc keeps this
+         # at 32.
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 #if defined _MIPS_SZLONG && (_MIPS_SZLONG == 64)
-                   int ok;
-                  #else
-                   error fail
-                  #endif
+                 int ok;
+                #else
+                 error fail
+                #endif
 
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi_32bit=no
+  gl_cv_host_cpu_c_abi=mips64
 else $as_nop
-  gl_cv_host_cpu_c_abi_32bit=yes
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-           ;;
-
-         powerpc* )
-           # Different ABIs are in use on AIX vs. Mac OS X vs. Linux,*BSD.
-           # No need to distinguish them here; the caller may distinguish
-           # them based on the OS.
-           # On powerpc64 systems, the C compiler may still be generating
-           # 32-bit code. And on powerpc-ibm-aix systems, the C compiler may
-           # be generating 64-bit code.
-           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  # In the n32 ABI, _ABIN32 is defined, _ABIO32 is not defined (but
+            # may later get defined by <sgidefs.h>), and _MIPS_SIM == _ABIN32.
+            # In the 32 ABI, _ABIO32 is defined, _ABIN32 is not defined (but
+            # may later get defined by <sgidefs.h>), and _MIPS_SIM == _ABIO32.
+            cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined __powerpc64__ || defined __LP64__
-                   int ok;
-                  #else
-                   error fail
-                  #endif
+#if (_MIPS_SIM == _ABIN32)
+                    int ok;
+                   #else
+                    error fail
+                   #endif
 
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi_32bit=no
+  gl_cv_host_cpu_c_abi=mipsn32
 else $as_nop
-  gl_cv_host_cpu_c_abi_32bit=yes
+  gl_cv_host_cpu_c_abi=mips
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-           ;;
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+         ;;
 
-         rs6000 )
-           gl_cv_host_cpu_c_abi_32bit=yes
-           ;;
+       powerpc* )
+         # Different ABIs are in use on AIX vs. Mac OS X vs. Linux,*BSD.
+         # No need to distinguish them here; the caller may distinguish
+         # them based on the OS.
+         # On powerpc64 systems, the C compiler may still be generating
+         # 32-bit code. And on powerpc-ibm-aix systems, the C compiler may
+         # be generating 64-bit code.
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __powerpc64__ || defined __LP64__
+                 int ok;
+                #else
+                 error fail
+                #endif
 
-         riscv32 | riscv64 )
-           # There are 6 ABIs: ilp32, ilp32f, ilp32d, lp64, lp64f, lp64d.
-           # Size of 'long' and 'void *':
-           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  # On powerpc64, there are two ABIs on Linux: The AIX compatible
+            # one and the ELFv2 one. The latter defines _CALL_ELF=2.
+            cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined __LP64__
+#if defined _CALL_ELF && _CALL_ELF == 2
                     int ok;
-                  #else
+                   #else
                     error fail
-                  #endif
+                   #endif
 
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi_32bit=no
+  gl_cv_host_cpu_c_abi=powerpc64-elfv2
 else $as_nop
-  gl_cv_host_cpu_c_abi_32bit=yes
+  gl_cv_host_cpu_c_abi=powerpc64
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-           ;;
 
-         s390* )
-           # On s390x, the C compiler may be generating 64-bit (= s390x) code
-           # or 31-bit (= s390) code.
-           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+else $as_nop
+  gl_cv_host_cpu_c_abi=powerpc
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+         ;;
+
+       rs6000 )
+         gl_cv_host_cpu_c_abi=powerpc
+         ;;
+
+       riscv32 | riscv64 )
+         # There are 2 architectures (with variants): rv32* and rv64*.
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined __LP64__ || defined __s390x__
-                    int ok;
-                  #else
-                    error fail
-                  #endif
+#if __riscv_xlen == 64
+                  int ok;
+                #else
+                  error fail
+                #endif
 
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi_32bit=no
+  cpu=riscv64
 else $as_nop
-  gl_cv_host_cpu_c_abi_32bit=yes
+  cpu=riscv32
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-           ;;
-
-         sparc | sparc64 )
-           # UltraSPARCs running Linux have `uname -m` = "sparc64", but the
-           # C compiler still generates 32-bit code.
-           cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+         # There are 6 ABIs: ilp32, ilp32f, ilp32d, lp64, lp64f, lp64d.
+         # Size of 'long' and 'void *':
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#if defined __sparcv9 || defined __arch64__
-                   int ok;
-                  #else
-                   error fail
-                  #endif
+#if defined __LP64__
+                  int ok;
+                #else
+                  error fail
+                #endif
 
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_host_cpu_c_abi_32bit=no
+  main_abi=lp64
 else $as_nop
-  gl_cv_host_cpu_c_abi_32bit=yes
+  main_abi=ilp32
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-           ;;
-
-         *)
-           gl_cv_host_cpu_c_abi_32bit=unknown
-           ;;
-       esac
-     fi
-
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_host_cpu_c_abi_32bit" >&5
-printf "%s\n" "$gl_cv_host_cpu_c_abi_32bit" >&6; }
-
-  HOST_CPU_C_ABI_32BIT="$gl_cv_host_cpu_c_abi_32bit"
-
-
-
-
+         # Float ABIs:
+         # __riscv_float_abi_double:
+         #   'float' and 'double' are passed in floating-point registers.
+         # __riscv_float_abi_single:
+         #   'float' are passed in floating-point registers.
+         # __riscv_float_abi_soft:
+         #   No values are passed in floating-point registers.
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __riscv_float_abi_double
+                  int ok;
+                #else
+                  error fail
+                #endif
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for ELF binary format" >&5
-printf %s "checking for ELF binary format... " >&6; }
-if test ${gl_cv_elf+y}
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
 then :
-  printf %s "(cached) " >&6
+  float_abi=d
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#ifdef __ELF__
-        Extensible Linking Format
-        #endif
+#if defined __riscv_float_abi_single
+                     int ok;
+                   #else
+                     error fail
+                   #endif
 
 _ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "Extensible Linking Format" >/dev/null 2>&1
+if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_elf=yes
+  float_abi=f
 else $as_nop
-  gl_cv_elf=no
+  float_abi=''
 fi
-rm -rf conftest*
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+         gl_cv_host_cpu_c_abi="${cpu}-${main_abi}${float_abi}"
+         ;;
 
+       s390* )
+         # On s390x, the C compiler may be generating 64-bit (= s390x) code
+         # or 31-bit (= s390) code.
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __LP64__ || defined __s390x__
+                  int ok;
+                #else
+                  error fail
+                #endif
 
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  gl_cv_host_cpu_c_abi=s390x
+else $as_nop
+  gl_cv_host_cpu_c_abi=s390
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_elf" >&5
-printf "%s\n" "$gl_cv_elf" >&6; }
-  if test $gl_cv_elf = yes; then
-    # Extract the ELF class of a file (5th byte) in decimal.
-    # Cf. https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#File_header
-    if od -A x < /dev/null >/dev/null 2>/dev/null; then
-      # Use POSIX od.
-      func_elfclass ()
-      {
-        od -A n -t d1 -j 4 -N 1
-      }
-    else
-      # Use BSD hexdump.
-      func_elfclass ()
-      {
-        dd bs=1 count=1 skip=4 2>/dev/null | hexdump -e '1/1 "%3d "'
-        echo
-      }
-    fi
-    # Use 'expr', not 'test', to compare the values of func_elfclass, because on
-    # Solaris 11 OpenIndiana and Solaris 11 OmniOS, the result is 001 or 002,
-    # not 1 or 2.
-    case $HOST_CPU_C_ABI_32BIT in
-      yes)
-        # 32-bit ABI.
-        acl_is_expected_elfclass ()
-        {
-          expr "`func_elfclass | sed -e 's/[ 	]//g'`" = 1 > /dev/null
-        }
-        ;;
-      no)
-        # 64-bit ABI.
-        acl_is_expected_elfclass ()
-        {
-          expr "`func_elfclass | sed -e 's/[ 	]//g'`" = 2 > /dev/null
-        }
-        ;;
-      *)
-        # Unknown.
-        acl_is_expected_elfclass ()
-        {
-          :
-        }
-        ;;
-    esac
-  else
-    acl_is_expected_elfclass ()
-    {
-      :
-    }
-  fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+         ;;
 
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for the common suffixes of directories in the library search path" >&5
-printf %s "checking for the common suffixes of directories in the library search path... " >&6; }
-if test ${acl_cv_libdirstems+y}
+       sparc | sparc64 )
+         # UltraSPARCs running Linux have `uname -m` = "sparc64", but the
+         # C compiler still generates 32-bit code.
+         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#if defined __sparcv9 || defined __arch64__
+                 int ok;
+                #else
+                 error fail
+                #endif
+
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
 then :
-  printf %s "(cached) " >&6
+  gl_cv_host_cpu_c_abi=sparc64
 else $as_nop
-            acl_libdirstem=lib
-     acl_libdirstem2=
-     acl_libdirstem3=
-     case "$host_os" in
-       solaris*)
-                                                      if test $HOST_CPU_C_ABI_32BIT = no; then
-           acl_libdirstem2=lib/64
-           case "$host_cpu" in
-             sparc*)        acl_libdirstem3=lib/sparcv9 ;;
-             i*86 | x86_64) acl_libdirstem3=lib/amd64 ;;
-           esac
-         fi
+  gl_cv_host_cpu_c_abi=sparc
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
          ;;
+
        *)
-                                                                                 searchpath=`(LC_ALL=C $CC $CPPFLAGS $CFLAGS -print-search-dirs) 2>/dev/null \
-                     | sed -n -e 's,^libraries: ,,p' | sed -e 's,^=,,'`
-         if test $HOST_CPU_C_ABI_32BIT != no; then
-           # 32-bit or unknown ABI.
-           if test -d /usr/lib32; then
-             acl_libdirstem2=lib32
-           fi
-         fi
-         if test $HOST_CPU_C_ABI_32BIT != yes; then
-           # 64-bit or unknown ABI.
-           if test -d /usr/lib64; then
-             acl_libdirstem3=lib64
-           fi
-         fi
-         if test -n "$searchpath"; then
-           acl_save_IFS="${IFS= 	}"; IFS=":"
-           for searchdir in $searchpath; do
-             if test -d "$searchdir"; then
-               case "$searchdir" in
-                 */lib32/ | */lib32 ) acl_libdirstem2=lib32 ;;
-                 */lib64/ | */lib64 ) acl_libdirstem3=lib64 ;;
-                 */../ | */.. )
-                   # Better ignore directories of this form. They are misleading.
-                   ;;
-                 *) searchdir=`cd "$searchdir" && pwd`
-                    case "$searchdir" in
-                      */lib32 ) acl_libdirstem2=lib32 ;;
-                      */lib64 ) acl_libdirstem3=lib64 ;;
-                    esac ;;
-               esac
-             fi
-           done
-           IFS="$acl_save_IFS"
-           if test $HOST_CPU_C_ABI_32BIT = yes; then
-             # 32-bit ABI.
-             acl_libdirstem3=
-           fi
-           if test $HOST_CPU_C_ABI_32BIT = no; then
-             # 64-bit ABI.
-             acl_libdirstem2=
-           fi
-         fi
+         gl_cv_host_cpu_c_abi="$host_cpu"
          ;;
      esac
-     test -n "$acl_libdirstem2" || acl_libdirstem2="$acl_libdirstem"
-     test -n "$acl_libdirstem3" || acl_libdirstem3="$acl_libdirstem"
-     acl_cv_libdirstems="$acl_libdirstem,$acl_libdirstem2,$acl_libdirstem3"
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $acl_cv_libdirstems" >&5
-printf "%s\n" "$acl_cv_libdirstems" >&6; }
-      acl_libdirstem=`echo "$acl_cv_libdirstems" | sed -e 's/,.*//'`
-  acl_libdirstem2=`echo "$acl_cv_libdirstems" | sed -e 's/^[^,]*,//' -e 's/,.*//'`
-  acl_libdirstem3=`echo "$acl_cv_libdirstems" | sed -e 's/^[^,]*,[^,]*,//' -e 's/,.*//'`
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_host_cpu_c_abi" >&5
+printf "%s\n" "$gl_cv_host_cpu_c_abi" >&6; }
+
+    HOST_CPU=`echo "$gl_cv_host_cpu_c_abi" | sed -e 's/-.*//'`
+  HOST_CPU_C_ABI="$gl_cv_host_cpu_c_abi"
+
+
+
+  # This was
+  #   AC_DEFINE_UNQUOTED([__${HOST_CPU}__])
+  #   AC_DEFINE_UNQUOTED([__${HOST_CPU_C_ABI}__])
+  # earlier, but KAI C++ 3.2d doesn't like this.
+  sed -e 's/-/_/g' >> confdefs.h <<EOF
+#ifndef __${HOST_CPU}__
+#define __${HOST_CPU}__ 1
+#endif
+#ifndef __${HOST_CPU_C_ABI}__
+#define __${HOST_CPU_C_ABI}__ 1
+#endif
+EOF
+
+
 
 
 
@@ -31945,13 +32561,12 @@
 
 
 
-    if test "$with_libsigsegv" = yes; then
-    if test "$gl_cv_lib_sigsegv" = yes; then
-      LIBCSTACK=$LIBSIGSEGV
 
-      LTLIBCSTACK=$LTLIBSIGSEGV
+  if test $gl_sigsegv_uses_libsigsegv = yes; then
+    LIBCSTACK=$LIBSIGSEGV
+
+    LTLIBCSTACK=$LTLIBSIGSEGV
 
-    fi
   fi
 
 
@@ -41697,554 +42312,90 @@
 then :
   printf "%s\n" "#define HAVE_PATHS_H 1" >>confdefs.h
 
-fi
-
-  ac_fn_c_check_func "$LINENO" "confstr" "ac_cv_func_confstr"
-if test "x$ac_cv_func_confstr" = xyes
-then :
-  printf "%s\n" "#define HAVE_CONFSTR 1" >>confdefs.h
-
-fi
-ac_fn_c_check_func "$LINENO" "sched_setparam" "ac_cv_func_sched_setparam"
-if test "x$ac_cv_func_sched_setparam" = xyes
-then :
-  printf "%s\n" "#define HAVE_SCHED_SETPARAM 1" >>confdefs.h
-
-fi
-ac_fn_c_check_func "$LINENO" "sched_setscheduler" "ac_cv_func_sched_setscheduler"
-if test "x$ac_cv_func_sched_setscheduler" = xyes
-then :
-  printf "%s\n" "#define HAVE_SCHED_SETSCHEDULER 1" >>confdefs.h
-
-fi
-ac_fn_c_check_func "$LINENO" "setegid" "ac_cv_func_setegid"
-if test "x$ac_cv_func_setegid" = xyes
-then :
-  printf "%s\n" "#define HAVE_SETEGID 1" >>confdefs.h
-
-fi
-ac_fn_c_check_func "$LINENO" "seteuid" "ac_cv_func_seteuid"
-if test "x$ac_cv_func_seteuid" = xyes
-then :
-  printf "%s\n" "#define HAVE_SETEUID 1" >>confdefs.h
-
-fi
-ac_fn_c_check_func "$LINENO" "vfork" "ac_cv_func_vfork"
-if test "x$ac_cv_func_vfork" = xyes
-then :
-  printf "%s\n" "#define HAVE_VFORK 1" >>confdefs.h
-
-fi
-
-
-  fi
-
-
-
-
-
-
-
-  if test $ac_cv_func_posix_spawn_file_actions_addchdir = yes; then
-            REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=1
-  else
-    HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=0
-  fi
-
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1 || test $HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR = 0 || test $REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR = 1; then
-
-
-
-
-
-
-
-
-  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_addchdir.$ac_objext"
-
-  fi
-
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR 1" >>confdefs.h
-
-
-
-
-
-
-
-
-
-  if test $REPLACE_POSIX_SPAWN = 1; then
-    REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCLOSE=1
-  else
-            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether posix_spawn_file_actions_addclose works" >&5
-printf %s "checking whether posix_spawn_file_actions_addclose works... " >&6; }
-if test ${gl_cv_func_posix_spawn_file_actions_addclose_works+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  if test "$cross_compiling" = yes
-then :
-  # Guess no on musl libc and Solaris, yes otherwise.
-          case "$host_os" in
-            *-musl*)  gl_cv_func_posix_spawn_file_actions_addclose_works="guessing no" ;;
-            solaris*) gl_cv_func_posix_spawn_file_actions_addclose_works="guessing no" ;;
-                      # Guess no on native Windows.
-            mingw*)   gl_cv_func_posix_spawn_file_actions_addclose_works="guessing no" ;;
-            *)        gl_cv_func_posix_spawn_file_actions_addclose_works="guessing yes" ;;
-          esac
-
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-
-#include <spawn.h>
-int main ()
-{
-  posix_spawn_file_actions_t actions;
-  if (posix_spawn_file_actions_init (&actions) != 0)
-    return 1;
-  if (posix_spawn_file_actions_addclose (&actions, -5) == 0)
-    return 2;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
-then :
-  gl_cv_func_posix_spawn_file_actions_addclose_works=yes
-else $as_nop
-  gl_cv_func_posix_spawn_file_actions_addclose_works=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-
-
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_posix_spawn_file_actions_addclose_works" >&5
-printf "%s\n" "$gl_cv_func_posix_spawn_file_actions_addclose_works" >&6; }
-    case "$gl_cv_func_posix_spawn_file_actions_addclose_works" in
-      *yes) ;;
-      *) REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCLOSE=1 ;;
-    esac
-  fi
-
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1 || test $REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCLOSE = 1; then
-
-
-
-
-
-
-
-
-  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_addclose.$ac_objext"
-
-  fi
-
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_ADDCLOSE=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_ADDCLOSE 1" >>confdefs.h
-
-
-
-
-
-
-
-
-
-  if test $REPLACE_POSIX_SPAWN = 1; then
-    REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDDUP2=1
-  else
-            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether posix_spawn_file_actions_adddup2 works" >&5
-printf %s "checking whether posix_spawn_file_actions_adddup2 works... " >&6; }
-if test ${gl_cv_func_posix_spawn_file_actions_adddup2_works+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  if test "$cross_compiling" = yes
-then :
-  # Guess no on musl libc and Solaris, yes otherwise.
-          case "$host_os" in
-            *-musl*)  gl_cv_func_posix_spawn_file_actions_adddup2_works="guessing no";;
-            solaris*) gl_cv_func_posix_spawn_file_actions_adddup2_works="guessing no";;
-                      # Guess no on native Windows.
-            mingw*)   gl_cv_func_posix_spawn_file_actions_adddup2_works="guessing no" ;;
-            *)        gl_cv_func_posix_spawn_file_actions_adddup2_works="guessing yes";;
-          esac
-
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-
-#include <spawn.h>
-int main ()
-{
-  posix_spawn_file_actions_t actions;
-  if (posix_spawn_file_actions_init (&actions) != 0)
-    return 1;
-  if (posix_spawn_file_actions_adddup2 (&actions, 10000000, 2) == 0)
-    return 2;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
-then :
-  gl_cv_func_posix_spawn_file_actions_adddup2_works=yes
-else $as_nop
-  gl_cv_func_posix_spawn_file_actions_adddup2_works=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-
-
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_posix_spawn_file_actions_adddup2_works" >&5
-printf "%s\n" "$gl_cv_func_posix_spawn_file_actions_adddup2_works" >&6; }
-    case "$gl_cv_func_posix_spawn_file_actions_adddup2_works" in
-      *yes) ;;
-      *) REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDDUP2=1 ;;
-    esac
-  fi
-
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1 || test $REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDDUP2 = 1; then
-
-
-
-
-
-
-
-
-  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_adddup2.$ac_objext"
-
-  fi
-
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_ADDDUP2=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_ADDDUP2 1" >>confdefs.h
-
-
-
-
-
-
-
-
-
-  if test $REPLACE_POSIX_SPAWN = 1; then
-    REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDOPEN=1
-  else
-            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether posix_spawn_file_actions_addopen works" >&5
-printf %s "checking whether posix_spawn_file_actions_addopen works... " >&6; }
-if test ${gl_cv_func_posix_spawn_file_actions_addopen_works+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  if test "$cross_compiling" = yes
-then :
-  # Guess no on musl libc and Solaris, yes otherwise.
-          case "$host_os" in
-            *-musl*)  gl_cv_func_posix_spawn_file_actions_addopen_works="guessing no";;
-            solaris*) gl_cv_func_posix_spawn_file_actions_addopen_works="guessing no";;
-                      # Guess no on native Windows.
-            mingw*)   gl_cv_func_posix_spawn_file_actions_addopen_works="guessing no" ;;
-            *)        gl_cv_func_posix_spawn_file_actions_addopen_works="guessing yes";;
-          esac
-
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-
-#include <spawn.h>
-#include <fcntl.h>
-int main ()
-{
-  posix_spawn_file_actions_t actions;
-  if (posix_spawn_file_actions_init (&actions) != 0)
-    return 1;
-  if (posix_spawn_file_actions_addopen (&actions, 10000000, "foo", 0, O_RDONLY)
-      == 0)
-    return 2;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
-then :
-  gl_cv_func_posix_spawn_file_actions_addopen_works=yes
-else $as_nop
-  gl_cv_func_posix_spawn_file_actions_addopen_works=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-
-
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_posix_spawn_file_actions_addopen_works" >&5
-printf "%s\n" "$gl_cv_func_posix_spawn_file_actions_addopen_works" >&6; }
-    case "$gl_cv_func_posix_spawn_file_actions_addopen_works" in
-      *yes) ;;
-      *) REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDOPEN=1 ;;
-    esac
-  fi
-
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1 || test $REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDOPEN = 1; then
-
-
-
-
-
-
-
-
-  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_addopen.$ac_objext"
-
-  fi
-
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_ADDOPEN=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_ADDOPEN 1" >>confdefs.h
-
-
-
-
-
-
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
-
-
-
-
-
-
-
-
-  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_destroy.$ac_objext"
-
-  fi
-
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_DESTROY=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_DESTROY 1" >>confdefs.h
-
-
-
-
-
-
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
-
-
-
-
-
-
-
-
-  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_init.$ac_objext"
-
-  fi
-
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_INIT=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_INIT 1" >>confdefs.h
-
-
-
-
-
-
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
-
-
-
-
-
-
-
-
-  M4_LIBOBJS="$M4_LIBOBJS spawnattr_destroy.$ac_objext"
-
-  fi
-
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_POSIX_SPAWNATTR_DESTROY=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNATTR_DESTROY 1" >>confdefs.h
-
-
-
-
-
-
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
-
-
-
-
-
-
-
-
-  M4_LIBOBJS="$M4_LIBOBJS spawnattr_init.$ac_objext"
-
-  fi
-
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_POSIX_SPAWNATTR_INIT=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNATTR_INIT 1" >>confdefs.h
-
-
+fi
 
+  ac_fn_c_check_func "$LINENO" "confstr" "ac_cv_func_confstr"
+if test "x$ac_cv_func_confstr" = xyes
+then :
+  printf "%s\n" "#define HAVE_CONFSTR 1" >>confdefs.h
 
+fi
+ac_fn_c_check_func "$LINENO" "sched_setparam" "ac_cv_func_sched_setparam"
+if test "x$ac_cv_func_sched_setparam" = xyes
+then :
+  printf "%s\n" "#define HAVE_SCHED_SETPARAM 1" >>confdefs.h
 
+fi
+ac_fn_c_check_func "$LINENO" "sched_setscheduler" "ac_cv_func_sched_setscheduler"
+if test "x$ac_cv_func_sched_setscheduler" = xyes
+then :
+  printf "%s\n" "#define HAVE_SCHED_SETSCHEDULER 1" >>confdefs.h
 
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
+fi
+ac_fn_c_check_func "$LINENO" "setegid" "ac_cv_func_setegid"
+if test "x$ac_cv_func_setegid" = xyes
+then :
+  printf "%s\n" "#define HAVE_SETEGID 1" >>confdefs.h
 
+fi
+ac_fn_c_check_func "$LINENO" "seteuid" "ac_cv_func_seteuid"
+if test "x$ac_cv_func_seteuid" = xyes
+then :
+  printf "%s\n" "#define HAVE_SETEUID 1" >>confdefs.h
 
+fi
+ac_fn_c_check_func "$LINENO" "vfork" "ac_cv_func_vfork"
+if test "x$ac_cv_func_vfork" = xyes
+then :
+  printf "%s\n" "#define HAVE_VFORK 1" >>confdefs.h
 
+fi
 
 
+  fi
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS spawnattr_setflags.$ac_objext"
 
-  fi
 
 
 
+  if test $ac_cv_func_posix_spawn_file_actions_addchdir = yes; then
+            REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=1
+  else
+    HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=0
+  fi
 
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1 || test $HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR = 0 || test $REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR = 1; then
 
 
 
 
 
-          GL_M4_GNULIB_POSIX_SPAWNATTR_SETFLAGS=1
 
 
 
+  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_addchdir.$ac_objext"
 
+  fi
 
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNATTR_SETFLAGS 1" >>confdefs.h
 
 
 
 
 
 
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
 
 
+          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR=1
 
 
 
 
 
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR 1" >>confdefs.h
 
-  M4_LIBOBJS="$M4_LIBOBJS spawnattr_setpgroup.$ac_objext"
 
-  fi
 
 
 
@@ -42252,23 +42403,73 @@
 
 
 
+  if test $REPLACE_POSIX_SPAWN = 1; then
+    REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCLOSE=1
+  else
+            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether posix_spawn_file_actions_addclose works" >&5
+printf %s "checking whether posix_spawn_file_actions_addclose works... " >&6; }
+if test ${gl_cv_func_posix_spawn_file_actions_addclose_works+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
+  # Guess no on musl libc and Solaris, yes otherwise.
+          case "$host_os" in
+            *-musl*)  gl_cv_func_posix_spawn_file_actions_addclose_works="guessing no" ;;
+            solaris*) gl_cv_func_posix_spawn_file_actions_addclose_works="guessing no" ;;
+                      # Guess no on native Windows.
+            mingw*)   gl_cv_func_posix_spawn_file_actions_addclose_works="guessing no" ;;
+            *)        gl_cv_func_posix_spawn_file_actions_addclose_works="guessing yes" ;;
+          esac
 
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
-          GL_M4_GNULIB_POSIX_SPAWNATTR_SETPGROUP=1
+#include <spawn.h>
+int main ()
+{
+  posix_spawn_file_actions_t actions;
+  if (posix_spawn_file_actions_init (&actions) != 0)
+    return 1;
+  if (posix_spawn_file_actions_addclose (&actions, -5) == 0)
+    return 2;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
+then :
+  gl_cv_func_posix_spawn_file_actions_addclose_works=yes
+else $as_nop
+  gl_cv_func_posix_spawn_file_actions_addclose_works=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
 
 
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_posix_spawn_file_actions_addclose_works" >&5
+printf "%s\n" "$gl_cv_func_posix_spawn_file_actions_addclose_works" >&6; }
+    case "$gl_cv_func_posix_spawn_file_actions_addclose_works" in
+      *yes) ;;
+      *) REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCLOSE=1 ;;
+    esac
+  fi
 
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1 || test $REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDCLOSE = 1; then
 
 
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNATTR_SETPGROUP 1" >>confdefs.h
 
 
 
 
 
 
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
+  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_addclose.$ac_objext"
 
+  fi
 
 
 
@@ -42276,32 +42477,80 @@
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS spawnattr_setsigmask.$ac_objext"
 
-  fi
 
+          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_ADDCLOSE=1
 
 
 
 
 
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_ADDCLOSE 1" >>confdefs.h
 
 
 
-          GL_M4_GNULIB_POSIX_SPAWNATTR_SETSIGMASK=1
 
 
 
 
 
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNATTR_SETSIGMASK 1" >>confdefs.h
 
+  if test $REPLACE_POSIX_SPAWN = 1; then
+    REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDDUP2=1
+  else
+            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether posix_spawn_file_actions_adddup2 works" >&5
+printf %s "checking whether posix_spawn_file_actions_adddup2 works... " >&6; }
+if test ${gl_cv_func_posix_spawn_file_actions_adddup2_works+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test "$cross_compiling" = yes
+then :
+  # Guess no on musl libc and Solaris, yes otherwise.
+          case "$host_os" in
+            *-musl*)  gl_cv_func_posix_spawn_file_actions_adddup2_works="guessing no";;
+            solaris*) gl_cv_func_posix_spawn_file_actions_adddup2_works="guessing no";;
+                      # Guess no on native Windows.
+            mingw*)   gl_cv_func_posix_spawn_file_actions_adddup2_works="guessing no" ;;
+            *)        gl_cv_func_posix_spawn_file_actions_adddup2_works="guessing yes";;
+          esac
 
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
+#include <spawn.h>
+int main ()
+{
+  posix_spawn_file_actions_t actions;
+  if (posix_spawn_file_actions_init (&actions) != 0)
+    return 1;
+  if (posix_spawn_file_actions_adddup2 (&actions, 10000000, 2) == 0)
+    return 2;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
+then :
+  gl_cv_func_posix_spawn_file_actions_adddup2_works=yes
+else $as_nop
+  gl_cv_func_posix_spawn_file_actions_adddup2_works=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
 
 
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_posix_spawn_file_actions_adddup2_works" >&5
+printf "%s\n" "$gl_cv_func_posix_spawn_file_actions_adddup2_works" >&6; }
+    case "$gl_cv_func_posix_spawn_file_actions_adddup2_works" in
+      *yes) ;;
+      *) REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDDUP2=1 ;;
+    esac
+  fi
 
-  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1 || test $REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDDUP2 = 1; then
 
 
 
@@ -42310,7 +42559,7 @@
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS spawnp.$ac_objext"
+  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_adddup2.$ac_objext"
 
   fi
 
@@ -42322,128 +42571,64 @@
 
 
 
-          GL_M4_GNULIB_POSIX_SPAWNP=1
+          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_ADDDUP2=1
 
 
 
 
 
-printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNP 1" >>confdefs.h
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_ADDDUP2 1" >>confdefs.h
 
 
 
 
 
-  if test $gl_cv_func_frexp_no_libm = yes; then
 
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether frexp works" >&5
-printf %s "checking whether frexp works... " >&6; }
-if test ${gl_cv_func_frexp_works+y}
+
+  if test $REPLACE_POSIX_SPAWN = 1; then
+    REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDOPEN=1
+  else
+            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether posix_spawn_file_actions_addopen works" >&5
+printf %s "checking whether posix_spawn_file_actions_addopen works... " >&6; }
+if test ${gl_cv_func_posix_spawn_file_actions_addopen_works+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-
-      if test "$cross_compiling" = yes
-then :
-  case "$host_os" in
-           netbsd* | irix*) gl_cv_func_frexp_works="guessing no" ;;
-           mingw*) # Guess yes with MSVC, no with mingw.
-             cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-
-#ifdef _MSC_VER
- Good
-#endif
-
-_ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "Good" >/dev/null 2>&1
+  if test "$cross_compiling" = yes
 then :
-  gl_cv_func_frexp_works="guessing yes"
-else $as_nop
-  gl_cv_func_frexp_works="guessing no"
-fi
-rm -rf conftest*
-
-             ;;
-           *) gl_cv_func_frexp_works="guessing yes" ;;
-         esac
+  # Guess no on musl libc and Solaris, yes otherwise.
+          case "$host_os" in
+            *-musl*)  gl_cv_func_posix_spawn_file_actions_addopen_works="guessing no";;
+            solaris*) gl_cv_func_posix_spawn_file_actions_addopen_works="guessing no";;
+                      # Guess no on native Windows.
+            mingw*)   gl_cv_func_posix_spawn_file_actions_addopen_works="guessing no" ;;
+            *)        gl_cv_func_posix_spawn_file_actions_addopen_works="guessing yes";;
+          esac
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
-#include <float.h>
-#include <math.h>
-#include <string.h>
-#if HAVE_DECL_ALARM
-# include <signal.h>
-# include <unistd.h>
-#endif
-/* HP cc on HP-UX 10.20 has a bug with the constant expression -0.0.
-   ICC 10.0 has a bug when optimizing the expression -zero.
-   The expression -DBL_MIN * DBL_MIN does not work when cross-compiling
-   to PowerPC on Mac OS X 10.5.  */
-#if defined __hpux || defined __sgi || defined __ICC
-static double
-compute_minus_zero (void)
-{
-  return -DBL_MIN * DBL_MIN;
-}
-# define minus_zero compute_minus_zero ()
-#else
-double minus_zero = -0.0;
-#endif
-int main()
+#include <spawn.h>
+#include <fcntl.h>
+int main ()
 {
-  int result = 0;
-  int i;
-  volatile double x;
-  double zero = 0.0;
-#if HAVE_DECL_ALARM
-  /* NeXTstep 3.3 frexp() runs into an endless loop when called on an infinite
-     number.  Let the test fail in this case.  */
-  signal (SIGALRM, SIG_DFL);
-  alarm (5);
-#endif
-  /* Test on denormalized numbers.  */
-  for (i = 1, x = 1.0; i >= DBL_MIN_EXP; i--, x *= 0.5)
-    ;
-  if (x > 0.0)
-    {
-      int exp;
-      double y = frexp (x, &exp);
-      /* On machines with IEEE754 arithmetic: x = 1.11254e-308, exp = -1022.
-         On NetBSD: y = 0.75. Correct: y = 0.5.  */
-      if (y != 0.5)
-        result |= 1;
-    }
-  /* Test on infinite numbers.  */
-  x = 1.0 / zero;
-  {
-    int exp;
-    double y = frexp (x, &exp);
-    if (y != x)
-      result |= 2;
-  }
-  /* Test on negative zero.  */
-  x = minus_zero;
-  {
-    int exp;
-    double y = frexp (x, &exp);
-    if (memcmp (&y, &x, sizeof x))
-      result |= 4;
-  }
-  return result;
+  posix_spawn_file_actions_t actions;
+  if (posix_spawn_file_actions_init (&actions) != 0)
+    return 1;
+  if (posix_spawn_file_actions_addopen (&actions, 10000000, "foo", 0, O_RDONLY)
+      == 0)
+    return 2;
+  return 0;
 }
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_func_frexp_works=yes
+  gl_cv_func_posix_spawn_file_actions_addopen_works=yes
 else $as_nop
-  gl_cv_func_frexp_works=no
+  gl_cv_func_posix_spawn_file_actions_addopen_works=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
@@ -42451,53 +42636,24 @@
 
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_frexp_works" >&5
-printf "%s\n" "$gl_cv_func_frexp_works" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_posix_spawn_file_actions_addopen_works" >&5
+printf "%s\n" "$gl_cv_func_posix_spawn_file_actions_addopen_works" >&6; }
+    case "$gl_cv_func_posix_spawn_file_actions_addopen_works" in
+      *yes) ;;
+      *) REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDOPEN=1 ;;
+    esac
+  fi
 
-    case "$gl_cv_func_frexp_works" in
-      *yes)
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1 || test $REPLACE_POSIX_SPAWN_FILE_ACTIONS_ADDOPEN = 1; then
 
-printf "%s\n" "#define HAVE_FREXP_IN_LIBC 1" >>confdefs.h
 
-        ;;
-    esac
-  fi
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ldexp can be used without linking with libm" >&5
-printf %s "checking whether ldexp can be used without linking with libm... " >&6; }
-if test ${gl_cv_func_ldexp_no_libm+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <math.h>
-             double x;
-             int y;
-int
-main (void)
-{
-return ldexp (x, y) < 1;
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"
-then :
-  gl_cv_func_ldexp_no_libm=yes
-else $as_nop
-  gl_cv_func_ldexp_no_libm=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ldexp_no_libm" >&5
-printf "%s\n" "$gl_cv_func_ldexp_no_libm" >&6; }
-  if test $gl_cv_func_ldexp_no_libm = yes; then
 
-printf "%s\n" "#define HAVE_LDEXP_IN_LIBC 1" >>confdefs.h
+
+
+  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_addopen.$ac_objext"
 
   fi
 
@@ -42506,414 +42662,138 @@
 
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether frexpl() can be used without linking with libm" >&5
-printf %s "checking whether frexpl() can be used without linking with libm... " >&6; }
-if test ${gl_cv_func_frexpl_no_libm+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <math.h>
-             long double x;
-int
-main (void)
-{
-int e; return frexpl (x, &e) > 0;
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"
-then :
-  gl_cv_func_frexpl_no_libm=yes
-else $as_nop
-  gl_cv_func_frexpl_no_libm=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_frexpl_no_libm" >&5
-printf "%s\n" "$gl_cv_func_frexpl_no_libm" >&6; }
 
-  if test $gl_cv_func_frexpl_no_libm = yes; then
+          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_ADDOPEN=1
 
 
-     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether frexpl works" >&5
-printf %s "checking whether frexpl works... " >&6; }
-if test ${gl_cv_func_frexpl_works+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-      if test "$cross_compiling" = yes
-then :
 
-         case "$host_os" in
-           aix | aix[3-6]* | beos* | darwin* | irix* | mingw* | pw*)
-              gl_cv_func_frexpl_works="guessing no";;
-           *) gl_cv_func_frexpl_works="guessing yes";;
-         esac
 
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_ADDOPEN 1" >>confdefs.h
+
+
+
+
+
+
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
+
+
+
+
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_destroy.$ac_objext"
+
+  fi
+
 
-#include <float.h>
-#include <math.h>
-/* Override the values of <float.h>, like done in float.in.h.  */
-#if defined __i386__ && (defined __BEOS__ || defined __OpenBSD__)
-# undef LDBL_MIN_EXP
-# define LDBL_MIN_EXP    (-16381)
-#endif
-#if defined __i386__ && (defined __FreeBSD__ || defined __DragonFly__)
-# undef LDBL_MIN_EXP
-# define LDBL_MIN_EXP    (-16381)
-#endif
-#if (defined _ARCH_PPC || defined _POWER) && defined _AIX && (LDBL_MANT_DIG == 106) && defined __GNUC__
-# undef LDBL_MIN_EXP
-# define LDBL_MIN_EXP DBL_MIN_EXP
-#endif
-#if defined __sgi && (LDBL_MANT_DIG >= 106)
-# if defined __GNUC__
-#  undef LDBL_MIN_EXP
-#  define LDBL_MIN_EXP DBL_MIN_EXP
-# endif
-#endif
-extern
-#ifdef __cplusplus
-"C"
-#endif
-long double frexpl (long double, int *);
-long double zero = 0.0L;
-int main()
-{
-  int result = 0;
-  volatile long double x;
-  /* Test on finite numbers that fails on AIX 5.1.  */
-  x = 16.0L;
-  {
-    int exp = -9999;
-    frexpl (x, &exp);
-    if (exp != 5)
-      result |= 1;
-  }
-  /* Test on finite numbers that fails on Mac OS X 10.4, because its frexpl
-     function returns an invalid (incorrectly normalized) value: it returns
-               y = { 0x3fe028f5, 0xc28f5c28, 0x3c9eb851, 0xeb851eb8 }
-     but the correct result is
-          0.505L = { 0x3fe028f5, 0xc28f5c29, 0xbc547ae1, 0x47ae1480 }  */
-  x = 1.01L;
-  {
-    int exp = -9999;
-    long double y = frexpl (x, &exp);
-    if (!(exp == 1 && y == 0.505L))
-      result |= 2;
-  }
-  /* Test on large finite numbers.  This fails on BeOS at i = 16322, while
-     LDBL_MAX_EXP = 16384.
-     In the loop end test, we test x against Infinity, rather than comparing
-     i with LDBL_MAX_EXP, because BeOS <float.h> has a wrong LDBL_MAX_EXP.  */
-  {
-    int i;
-    for (i = 1, x = 1.0L; x != x + x; i++, x *= 2.0L)
-      {
-        int exp = -9999;
-        frexpl (x, &exp);
-        if (exp != i)
-          {
-            result |= 4;
-            break;
-          }
-      }
-  }
-  /* Test on denormalized numbers.  */
-  {
-    int i;
-    for (i = 1, x = 1.0L; i >= LDBL_MIN_EXP; i--, x *= 0.5L)
-      ;
-    if (x > 0.0L)
-      {
-        int exp;
-        long double y = frexpl (x, &exp);
-        /* On machines with IEEE854 arithmetic: x = 1.68105e-4932,
-           exp = -16382, y = 0.5.  On Mac OS X 10.5: exp = -16384, y = 0.5.  */
-        if (exp != LDBL_MIN_EXP - 1)
-          result |= 8;
-      }
-  }
-  /* Test on infinite numbers.  */
-  /* The Microsoft MSVC 14 compiler chokes on the expression 1.0 / 0.0.  */
-  x = 1.0L / zero;
-  {
-    int exp;
-    long double y = frexpl (x, &exp);
-    if (y != x)
-      result |= 16;
-  }
-  return result;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
-then :
-  gl_cv_func_frexpl_works=yes
-else $as_nop
-  gl_cv_func_frexpl_works=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
 
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_frexpl_works" >&5
-printf "%s\n" "$gl_cv_func_frexpl_works" >&6; }
 
-    case "$gl_cv_func_frexpl_works" in
-      *yes) gl_func_frexpl_no_libm=yes ;;
-      *)    gl_func_frexpl_no_libm=no; REPLACE_FREXPL=1 ;;
-    esac
-  else
-    gl_func_frexpl_no_libm=no
-        REPLACE_FREXPL=1
-  fi
-  if test $gl_func_frexpl_no_libm = yes; then
 
-printf "%s\n" "#define HAVE_FREXPL_IN_LIBC 1" >>confdefs.h
 
-            ac_fn_check_decl "$LINENO" "frexpl" "ac_cv_have_decl_frexpl" "#include <math.h>
-" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_frexpl" = xyes
-then :
 
-else $as_nop
-  HAVE_DECL_FREXPL=0
-fi
-  fi
 
+          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_DESTROY=1
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ldexpl() can be used without linking with libm" >&5
-printf %s "checking whether ldexpl() can be used without linking with libm... " >&6; }
-if test ${gl_cv_func_ldexpl_no_libm+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <math.h>
-             long double x;
-int
-main (void)
-{
-return ldexpl (x, -1) > 0;
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"
-then :
-  gl_cv_func_ldexpl_no_libm=yes
-else $as_nop
-  gl_cv_func_ldexpl_no_libm=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ldexpl_no_libm" >&5
-printf "%s\n" "$gl_cv_func_ldexpl_no_libm" >&6; }
 
-  if test $gl_cv_func_ldexpl_no_libm = yes; then
 
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_DESTROY 1" >>confdefs.h
 
-     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ldexpl works" >&5
-printf %s "checking whether ldexpl works... " >&6; }
-if test ${gl_cv_func_ldexpl_works+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-      if test "$cross_compiling" = yes
-then :
 
-         case "$host_os" in
-           aix | aix[3-6]*) gl_cv_func_ldexpl_works="guessing no" ;;
-                            # Guess yes on native Windows.
-           mingw*)          gl_cv_func_ldexpl_works="guessing yes" ;;
-           *)               gl_cv_func_ldexpl_works="guessing yes" ;;
-         esac
 
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
 
-#include <math.h>
-extern
-#ifdef __cplusplus
-"C"
-#endif
-long double ldexpl (long double, int);
-int main()
-{
-  int result = 0;
-  {
-    volatile long double x = 1.0;
-    volatile long double y = ldexpl (x, -1);
-    if (y != 0.5L)
-      result |= 1;
-  }
-  {
-    volatile long double x = 1.73205L;
-    volatile long double y = ldexpl (x, 0);
-    if (y != x)
-      result |= 2;
-  }
-  return result;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
-then :
-  gl_cv_func_ldexpl_works=yes
-else $as_nop
-  gl_cv_func_ldexpl_works=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
 
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ldexpl_works" >&5
-printf "%s\n" "$gl_cv_func_ldexpl_works" >&6; }
 
-    case "$gl_cv_func_ldexpl_works" in
-      *yes)
 
-printf "%s\n" "#define HAVE_LDEXPL_IN_LIBC 1" >>confdefs.h
 
-                        ac_fn_check_decl "$LINENO" "ldexpl" "ac_cv_have_decl_ldexpl" "#include <math.h>
-" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_ldexpl" = xyes
-then :
 
-else $as_nop
-  HAVE_DECL_LDEXPL=0
-fi
-        ;;
-    esac
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS spawn_faction_init.$ac_objext"
+
   fi
 
 
-  ac_fn_check_decl "$LINENO" "program_invocation_name" "ac_cv_have_decl_program_invocation_name" "#include <errno.h>
-" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_program_invocation_name" = xyes
-then :
-  ac_have_decl=1
-else $as_nop
-  ac_have_decl=0
-fi
-printf "%s\n" "#define HAVE_DECL_PROGRAM_INVOCATION_NAME $ac_have_decl" >>confdefs.h
 
-  ac_fn_check_decl "$LINENO" "program_invocation_short_name" "ac_cv_have_decl_program_invocation_short_name" "#include <errno.h>
-" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_program_invocation_short_name" = xyes
-then :
-  ac_have_decl=1
-else $as_nop
-  ac_have_decl=0
-fi
-printf "%s\n" "#define HAVE_DECL_PROGRAM_INVOCATION_SHORT_NAME $ac_have_decl" >>confdefs.h
 
 
 
-  XGETTEXT_EXTRA_OPTIONS="$XGETTEXT_EXTRA_OPTIONS --keyword='proper_name:1,\"This is a proper name. See the gettext manual, section Names.\"'"
 
 
 
-  XGETTEXT_EXTRA_OPTIONS="$XGETTEXT_EXTRA_OPTIONS --keyword='proper_name_utf8:1,\"This is a proper name. See the gettext manual, section Names.\"'"
+          GL_M4_GNULIB_POSIX_SPAWN_FILE_ACTIONS_INIT=1
 
 
 
-  :
 
 
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWN_FILE_ACTIONS_INIT 1" >>confdefs.h
 
 
-  ac_fn_c_check_func "$LINENO" "raise" "ac_cv_func_raise"
-if test "x$ac_cv_func_raise" = xyes
-then :
-  printf "%s\n" "#define HAVE_RAISE 1" >>confdefs.h
 
-fi
 
-  if test $ac_cv_func_raise = no; then
-    HAVE_RAISE=0
-  else
 
 
-      if test $HAVE_MSVC_INVALID_PARAMETER_HANDLER = 1; then
-        REPLACE_RAISE=1
-      fi
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
+
+
 
 
 
 
 
-  HAVE_POSIX_SIGNALBLOCKING=0
-  if test "$gl_cv_type_sigset_t" = yes; then
-    ac_fn_c_check_func "$LINENO" "sigprocmask" "ac_cv_func_sigprocmask"
-if test "x$ac_cv_func_sigprocmask" = xyes
-then :
-  HAVE_POSIX_SIGNALBLOCKING=1
-fi
+
+  M4_LIBOBJS="$M4_LIBOBJS spawnattr_destroy.$ac_objext"
 
   fi
 
-      if test $HAVE_POSIX_SIGNALBLOCKING = 0; then
 
 
 
 
-          if test $gl_cv_header_signal_h_SIGPIPE != yes; then
-            REPLACE_RAISE=1
-          fi
 
-      fi
 
-  fi
 
-  if test $HAVE_RAISE = 0 || test $REPLACE_RAISE = 1; then
 
+          GL_M4_GNULIB_POSIX_SPAWNATTR_DESTROY=1
 
 
 
 
 
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNATTR_DESTROY 1" >>confdefs.h
 
 
-  M4_LIBOBJS="$M4_LIBOBJS raise.$ac_objext"
 
-    :
-  fi
 
 
 
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
 
 
 
 
 
 
-          GL_M4_GNULIB_RAISE=1
 
 
+  M4_LIBOBJS="$M4_LIBOBJS spawnattr_init.$ac_objext"
 
+  fi
 
 
-printf "%s\n" "#define GNULIB_TEST_RAISE 1" >>confdefs.h
 
 
 
@@ -42921,29 +42801,30 @@
 
 
 
-  ac_fn_c_check_func "$LINENO" "rawmemchr" "ac_cv_func_rawmemchr"
-if test "x$ac_cv_func_rawmemchr" = xyes
-then :
-  printf "%s\n" "#define HAVE_RAWMEMCHR 1" >>confdefs.h
+          GL_M4_GNULIB_POSIX_SPAWNATTR_INIT=1
 
-fi
 
-  if test $ac_cv_func_rawmemchr = no; then
-    HAVE_RAWMEMCHR=0
-  fi
 
-  if test $HAVE_RAWMEMCHR = 0; then
 
 
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNATTR_INIT 1" >>confdefs.h
 
 
 
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS rawmemchr.$ac_objext"
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
+
+
+
+
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS spawnattr_setflags.$ac_objext"
 
-    :
   fi
 
 
@@ -42954,31 +42835,32 @@
 
 
 
-          GL_M4_GNULIB_RAWMEMCHR=1
+          GL_M4_GNULIB_POSIX_SPAWNATTR_SETFLAGS=1
 
 
 
 
 
-printf "%s\n" "#define GNULIB_TEST_RAWMEMCHR 1" >>confdefs.h
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNATTR_SETFLAGS 1" >>confdefs.h
 
 
 
 
 
 
-  ac_fn_c_check_func "$LINENO" "readdir" "ac_cv_func_readdir"
-if test "x$ac_cv_func_readdir" = xyes
-then :
-  printf "%s\n" "#define HAVE_READDIR 1" >>confdefs.h
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
 
-fi
 
-  if test $ac_cv_func_readdir = no; then
-    HAVE_READDIR=0
+
+
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS spawnattr_setpgroup.$ac_objext"
+
   fi
 
-  if test $HAVE_READDIR = 0; then
 
 
 
@@ -42987,206 +42869,63 @@
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS readdir.$ac_objext"
+          GL_M4_GNULIB_POSIX_SPAWNATTR_SETPGROUP=1
 
-  fi
 
 
 
 
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNATTR_SETPGROUP 1" >>confdefs.h
 
 
 
 
 
-          GL_M4_GNULIB_READDIR=1
 
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
 
 
 
 
-printf "%s\n" "#define GNULIB_TEST_READDIR 1" >>confdefs.h
 
 
 
 
+  M4_LIBOBJS="$M4_LIBOBJS spawnattr_setsigmask.$ac_objext"
 
+  fi
 
-  if test $ac_cv_func_readlink = no; then
-    HAVE_READLINK=0
-  else
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether readlink signature is correct" >&5
-printf %s "checking whether readlink signature is correct... " >&6; }
-if test ${gl_cv_decl_readlink_works+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <unistd.h>
-      /* Cause compilation failure if original declaration has wrong type.  */
-      ssize_t readlink (const char *, char *, size_t);
-int
-main (void)
-{
 
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  gl_cv_decl_readlink_works=yes
-else $as_nop
-  gl_cv_decl_readlink_works=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_decl_readlink_works" >&5
-printf "%s\n" "$gl_cv_decl_readlink_works" >&6; }
-            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether readlink handles trailing slash correctly" >&5
-printf %s "checking whether readlink handles trailing slash correctly... " >&6; }
-if test ${gl_cv_func_readlink_trailing_slash+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  # We have readlink, so assume ln -s works.
-       ln -s conftest.no-such conftest.link
-       ln -s conftest.link conftest.lnk2
-       if test "$cross_compiling" = yes
-then :
-  case "$host_os" in
-            # Guess yes on Linux or glibc systems.
-            linux-* | linux | *-gnu* | gnu*)
-              gl_cv_func_readlink_trailing_slash="guessing yes" ;;
-            # Guess no on AIX or HP-UX.
-            aix* | hpux*)
-              gl_cv_func_readlink_trailing_slash="guessing no" ;;
-            # If we don't know, obey --enable-cross-guesses.
-            *)
-              gl_cv_func_readlink_trailing_slash="$gl_cross_guess_normal" ;;
-          esac
 
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <unistd.h>
 
-int
-main (void)
-{
-char buf[20];
-      return readlink ("conftest.lnk2/", buf, sizeof buf) != -1;
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
-then :
-  gl_cv_func_readlink_trailing_slash=yes
-else $as_nop
-  gl_cv_func_readlink_trailing_slash=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
 
-      rm -f conftest.link conftest.lnk2
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_readlink_trailing_slash" >&5
-printf "%s\n" "$gl_cv_func_readlink_trailing_slash" >&6; }
-    case "$gl_cv_func_readlink_trailing_slash" in
-      *yes)
-        if test "$gl_cv_decl_readlink_works" != yes; then
-          REPLACE_READLINK=1
-        fi
-        ;;
-      *)
 
-printf "%s\n" "#define READLINK_TRAILING_SLASH_BUG 1" >>confdefs.h
 
-        REPLACE_READLINK=1
-        ;;
-    esac
 
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether readlink truncates results correctly" >&5
-printf %s "checking whether readlink truncates results correctly... " >&6; }
-if test ${gl_cv_func_readlink_truncate+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  # We have readlink, so assume ln -s works.
-       ln -s ab conftest.link
-       if test "$cross_compiling" = yes
-then :
-  case "$host_os" in
-            # Guess yes on Linux or glibc systems.
-            linux-* | linux | *-gnu* | gnu*)
-              gl_cv_func_readlink_truncate="guessing yes" ;;
-            # Guess no on AIX or HP-UX.
-            aix* | hpux*)
-              gl_cv_func_readlink_truncate="guessing no" ;;
-            # If we don't know, obey --enable-cross-guesses.
-            *)
-              gl_cv_func_readlink_truncate="$gl_cross_guess_normal" ;;
-          esac
 
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <unistd.h>
+          GL_M4_GNULIB_POSIX_SPAWNATTR_SETSIGMASK=1
 
-int
-main (void)
-{
-char c;
-      return readlink ("conftest.link", &c, 1) != 1;
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
-then :
-  gl_cv_func_readlink_truncate=yes
-else $as_nop
-  gl_cv_func_readlink_truncate=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
 
-      rm -f conftest.link conftest.lnk2
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_readlink_truncate" >&5
-printf "%s\n" "$gl_cv_func_readlink_truncate" >&6; }
-    case $gl_cv_func_readlink_truncate in
-      *yes)
-        if test "$gl_cv_decl_readlink_works" != yes; then
-          REPLACE_READLINK=1
-        fi
-        ;;
-      *)
 
-printf "%s\n" "#define READLINK_TRUNCATE_BUG 1" >>confdefs.h
 
-        REPLACE_READLINK=1
-        ;;
-    esac
-  fi
 
-  if test $HAVE_READLINK = 0 || test $REPLACE_READLINK = 1; then
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNATTR_SETSIGMASK 1" >>confdefs.h
 
 
 
 
 
 
+  if test $HAVE_POSIX_SPAWN = 0 || test $REPLACE_POSIX_SPAWN = 1; then
 
 
-  M4_LIBOBJS="$M4_LIBOBJS readlink.$ac_objext"
 
 
-  :
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS spawnp.$ac_objext"
 
   fi
 
@@ -43198,61 +42937,128 @@
 
 
 
-          GL_M4_GNULIB_READLINK=1
+          GL_M4_GNULIB_POSIX_SPAWNP=1
 
 
 
 
 
-printf "%s\n" "#define GNULIB_TEST_READLINK 1" >>confdefs.h
+printf "%s\n" "#define GNULIB_TEST_POSIX_SPAWNP 1" >>confdefs.h
 
 
 
 
 
+  if test $gl_cv_func_frexp_no_libm = yes; then
 
-  if test $REPLACE_REALLOC = 0; then
 
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether realloc (0, 0) returns nonnull" >&5
-printf %s "checking whether realloc (0, 0) returns nonnull... " >&6; }
-if test ${ac_cv_func_realloc_0_nonnull+y}
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether frexp works" >&5
+printf %s "checking whether frexp works... " >&6; }
+if test ${gl_cv_func_frexp_works+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  if test "$cross_compiling" = yes
+
+      if test "$cross_compiling" = yes
 then :
   case "$host_os" in
-          # Guess yes on platforms where we know the result.
-          *-gnu* | freebsd* | netbsd* | openbsd* | bitrig* \
-          | gnu* | *-musl* | midnightbsd* \
-          | hpux* | solaris* | cygwin* | mingw* | msys* )
-            ac_cv_func_realloc_0_nonnull="guessing yes" ;;
-          # If we don't know, obey --enable-cross-guesses.
-          *) ac_cv_func_realloc_0_nonnull="$gl_cross_guess_normal" ;;
-        esac
+           netbsd* | irix*) gl_cv_func_frexp_works="guessing no" ;;
+           mingw*) # Guess yes with MSVC, no with mingw.
+             cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+#ifdef _MSC_VER
+ Good
+#endif
+
+_ACEOF
+if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
+  $EGREP "Good" >/dev/null 2>&1
+then :
+  gl_cv_func_frexp_works="guessing yes"
+else $as_nop
+  gl_cv_func_frexp_works="guessing no"
+fi
+rm -rf conftest*
+
+             ;;
+           *) gl_cv_func_frexp_works="guessing yes" ;;
+         esac
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <stdlib.h>
 
-int
-main (void)
+#include <float.h>
+#include <math.h>
+#include <string.h>
+#if HAVE_DECL_ALARM
+# include <signal.h>
+# include <unistd.h>
+#endif
+/* HP cc on HP-UX 10.20 has a bug with the constant expression -0.0.
+   ICC 10.0 has a bug when optimizing the expression -zero.
+   The expression -DBL_MIN * DBL_MIN does not work when cross-compiling
+   to PowerPC on Mac OS X 10.5.  */
+#if defined __hpux || defined __sgi || defined __ICC
+static double
+compute_minus_zero (void)
 {
-void *p = realloc (0, 0);
-            int result = !p;
-            free (p);
-            return result;
-  ;
-  return 0;
+  return -DBL_MIN * DBL_MIN;
+}
+# define minus_zero compute_minus_zero ()
+#else
+double minus_zero = -0.0;
+#endif
+int main()
+{
+  int result = 0;
+  int i;
+  volatile double x;
+  double zero = 0.0;
+#if HAVE_DECL_ALARM
+  /* NeXTstep 3.3 frexp() runs into an endless loop when called on an infinite
+     number.  Let the test fail in this case.  */
+  signal (SIGALRM, SIG_DFL);
+  alarm (5);
+#endif
+  /* Test on denormalized numbers.  */
+  for (i = 1, x = 1.0; i >= DBL_MIN_EXP; i--, x *= 0.5)
+    ;
+  if (x > 0.0)
+    {
+      int exp;
+      double y = frexp (x, &exp);
+      /* On machines with IEEE754 arithmetic: x = 1.11254e-308, exp = -1022.
+         On NetBSD: y = 0.75. Correct: y = 0.5.  */
+      if (y != 0.5)
+        result |= 1;
+    }
+  /* Test on infinite numbers.  */
+  x = 1.0 / zero;
+  {
+    int exp;
+    double y = frexp (x, &exp);
+    if (y != x)
+      result |= 2;
+  }
+  /* Test on negative zero.  */
+  x = minus_zero;
+  {
+    int exp;
+    double y = frexp (x, &exp);
+    if (memcmp (&y, &x, sizeof x))
+      result |= 4;
+  }
+  return result;
 }
-
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  ac_cv_func_realloc_0_nonnull=yes
+  gl_cv_func_frexp_works=yes
 else $as_nop
-  ac_cv_func_realloc_0_nonnull=no
+  gl_cv_func_frexp_works=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
@@ -43260,425 +43066,334 @@
 
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_realloc_0_nonnull" >&5
-printf "%s\n" "$ac_cv_func_realloc_0_nonnull" >&6; }
-  case $ac_cv_func_realloc_0_nonnull in #(
-  *yes) :
-     ;; #(
-  *) :
-    REPLACE_REALLOC=1 ;;
-esac
-
-  fi
-
-  if test $REPLACE_REALLOC = 1; then
-
-
-
-
-
-
-
-
-  M4_LIBOBJS="$M4_LIBOBJS realloc.$ac_objext"
-
-  fi
-
-
-
-  if test $REPLACE_MALLOC = 1; then
-    REPLACE_REALLOC=1
-  fi
-
-  if test $REPLACE_REALLOC = 1; then
-
-
-
-
-
-
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_frexp_works" >&5
+printf "%s\n" "$gl_cv_func_frexp_works" >&6; }
 
+    case "$gl_cv_func_frexp_works" in
+      *yes)
 
-  M4_LIBOBJS="$M4_LIBOBJS realloc.$ac_objext"
+printf "%s\n" "#define HAVE_FREXP_IN_LIBC 1" >>confdefs.h
 
+        ;;
+    esac
   fi
 
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_REALLOC_POSIX=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_REALLOC_POSIX 1" >>confdefs.h
-
-
-
-
-
-
-
-
-  ac_fn_c_check_func "$LINENO" "reallocarray" "ac_cv_func_reallocarray"
-if test "x$ac_cv_func_reallocarray" = xyes
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ldexp can be used without linking with libm" >&5
+printf %s "checking whether ldexp can be used without linking with libm... " >&6; }
+if test ${gl_cv_func_ldexp_no_libm+y}
 then :
-  printf "%s\n" "#define HAVE_REALLOCARRAY 1" >>confdefs.h
+  printf %s "(cached) " >&6
+else $as_nop
 
+      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <math.h>
+             double x;
+             int y;
+int
+main (void)
+{
+return ldexp (x, y) < 1;
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"
+then :
+  gl_cv_func_ldexp_no_libm=yes
+else $as_nop
+  gl_cv_func_ldexp_no_libm=no
 fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
 
-  if test "$ac_cv_func_reallocarray" = no; then
-    HAVE_REALLOCARRAY=0
-  elif test "$gl_cv_malloc_ptrdiff" = no; then
-    REPLACE_REALLOCARRAY=1
-  fi
-
-  if test $HAVE_REALLOCARRAY = 0 || test $REPLACE_REALLOCARRAY = 1; then
-
-
-
-
-
-
-
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ldexp_no_libm" >&5
+printf "%s\n" "$gl_cv_func_ldexp_no_libm" >&6; }
+  if test $gl_cv_func_ldexp_no_libm = yes; then
 
-  M4_LIBOBJS="$M4_LIBOBJS reallocarray.$ac_objext"
+printf "%s\n" "#define HAVE_LDEXP_IN_LIBC 1" >>confdefs.h
 
-    :
   fi
 
 
-printf "%s\n" "#define GNULIB_REALLOCARRAY 1" >>confdefs.h
-
-
-
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_REALLOCARRAY=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_REALLOCARRAY 1" >>confdefs.h
 
 
 
 
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether frexpl() can be used without linking with libm" >&5
+printf %s "checking whether frexpl() can be used without linking with libm... " >&6; }
+if test ${gl_cv_func_frexpl_no_libm+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
-# Check whether --with-included-regex was given.
-if test ${with_included_regex+y}
+      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <math.h>
+             long double x;
+int
+main (void)
+{
+int e; return frexpl (x, &e) > 0;
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"
 then :
-  withval=$with_included_regex;
+  gl_cv_func_frexpl_no_libm=yes
+else $as_nop
+  gl_cv_func_frexpl_no_libm=no
 fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
 
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_frexpl_no_libm" >&5
+printf "%s\n" "$gl_cv_func_frexpl_no_libm" >&6; }
 
-  case $with_included_regex in #(
-  yes|no) ac_use_included_regex=$with_included_regex
-        ;;
-  '')
-    # If the system regex support is good enough that it passes the
-    # following run test, then default to *not* using the included regex.c.
-    # If cross compiling, assume the test would fail and use the included
-    # regex.c.
+  if test $gl_cv_func_frexpl_no_libm = yes; then
 
 
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working re_compile_pattern" >&5
-printf %s "checking for working re_compile_pattern... " >&6; }
-if test ${gl_cv_func_re_compile_pattern_working+y}
+     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether frexpl works" >&5
+printf %s "checking whether frexpl works... " >&6; }
+if test ${gl_cv_func_frexpl_works+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  if test "$cross_compiling" = yes
+
+      if test "$cross_compiling" = yes
 then :
-  case "$host_os" in
-                   # Guess no on native Windows.
-           mingw*) gl_cv_func_re_compile_pattern_working="guessing no" ;;
-                   # Otherwise obey --enable-cross-guesses.
-           *)      gl_cv_func_re_compile_pattern_working="$gl_cross_guess_normal" ;;
+
+         case "$host_os" in
+           aix | aix[3-6]* | beos* | darwin* | irix* | mingw* | pw*)
+              gl_cv_func_frexpl_works="guessing no";;
+           *) gl_cv_func_frexpl_works="guessing yes";;
          esac
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <regex.h>
-
-            #include <locale.h>
-            #include <limits.h>
-            #include <string.h>
-
-            #if defined M_CHECK_ACTION || HAVE_DECL_ALARM
-            # include <signal.h>
-            # include <unistd.h>
-            #endif
-
-            #if HAVE_MALLOC_H
-            # include <malloc.h>
-            #endif
-
-            #ifdef M_CHECK_ACTION
-            /* Exit with distinguishable exit code.  */
-            static void sigabrt_no_core (int sig) { raise (SIGTERM); }
-            #endif
-
-int
-main (void)
-{
-int result = 0;
-            static struct re_pattern_buffer regex;
-            unsigned char folded_chars[UCHAR_MAX + 1];
-            int i;
-            const char *s;
-            struct re_registers regs;
 
-            /* Some builds of glibc go into an infinite loop on this
-               test.  Use alarm to force death, and mallopt to avoid
-               malloc recursion in diagnosing the corrupted heap. */
-#if HAVE_DECL_ALARM
-            signal (SIGALRM, SIG_DFL);
-            alarm (2);
+#include <float.h>
+#include <math.h>
+/* Override the values of <float.h>, like done in float.in.h.  */
+#if defined __i386__ && (defined __BEOS__ || defined __OpenBSD__)
+# undef LDBL_MIN_EXP
+# define LDBL_MIN_EXP    (-16381)
 #endif
-#ifdef M_CHECK_ACTION
-            signal (SIGABRT, sigabrt_no_core);
-            mallopt (M_CHECK_ACTION, 2);
+#if defined __i386__ && (defined __FreeBSD__ || defined __DragonFly__)
+# undef LDBL_MIN_EXP
+# define LDBL_MIN_EXP    (-16381)
+#endif
+#if (defined _ARCH_PPC || defined _POWER) && defined _AIX && (LDBL_MANT_DIG == 106) && defined __GNUC__
+# undef LDBL_MIN_EXP
+# define LDBL_MIN_EXP DBL_MIN_EXP
+#endif
+#if defined __sgi && (LDBL_MANT_DIG >= 106)
+# if defined __GNUC__
+#  undef LDBL_MIN_EXP
+#  define LDBL_MIN_EXP DBL_MIN_EXP
+# endif
+#endif
+extern
+#ifdef __cplusplus
+"C"
 #endif
+long double frexpl (long double, int *);
+long double zero = 0.0L;
+int main()
+{
+  int result = 0;
+  volatile long double x;
+  /* Test on finite numbers that fails on AIX 5.1.  */
+  x = 16.0L;
+  {
+    int exp = -9999;
+    frexpl (x, &exp);
+    if (exp != 5)
+      result |= 1;
+  }
+  /* Test on finite numbers that fails on Mac OS X 10.4, because its frexpl
+     function returns an invalid (incorrectly normalized) value: it returns
+               y = { 0x3fe028f5, 0xc28f5c28, 0x3c9eb851, 0xeb851eb8 }
+     but the correct result is
+          0.505L = { 0x3fe028f5, 0xc28f5c29, 0xbc547ae1, 0x47ae1480 }  */
+  x = 1.01L;
+  {
+    int exp = -9999;
+    long double y = frexpl (x, &exp);
+    if (!(exp == 1 && y == 0.505L))
+      result |= 2;
+  }
+  /* Test on large finite numbers.  This fails on BeOS at i = 16322, while
+     LDBL_MAX_EXP = 16384.
+     In the loop end test, we test x against Infinity, rather than comparing
+     i with LDBL_MAX_EXP, because BeOS <float.h> has a wrong LDBL_MAX_EXP.  */
+  {
+    int i;
+    for (i = 1, x = 1.0L; x != x + x; i++, x *= 2.0L)
+      {
+        int exp = -9999;
+        frexpl (x, &exp);
+        if (exp != i)
+          {
+            result |= 4;
+            break;
+          }
+      }
+  }
+  /* Test on denormalized numbers.  */
+  {
+    int i;
+    for (i = 1, x = 1.0L; i >= LDBL_MIN_EXP; i--, x *= 0.5L)
+      ;
+    if (x > 0.0L)
+      {
+        int exp;
+        long double y = frexpl (x, &exp);
+        /* On machines with IEEE854 arithmetic: x = 1.68105e-4932,
+           exp = -16382, y = 0.5.  On Mac OS X 10.5: exp = -16384, y = 0.5.  */
+        if (exp != LDBL_MIN_EXP - 1)
+          result |= 8;
+      }
+  }
+  /* Test on infinite numbers.  */
+  /* The Microsoft MSVC 14 compiler chokes on the expression 1.0 / 0.0.  */
+  x = 1.0L / zero;
+  {
+    int exp;
+    long double y = frexpl (x, &exp);
+    if (y != x)
+      result |= 16;
+  }
+  return result;
+}
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
+then :
+  gl_cv_func_frexpl_works=yes
+else $as_nop
+  gl_cv_func_frexpl_works=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
 
-            if (setlocale (LC_ALL, "en_US.UTF-8"))
-              {
-                {
-                  /* https://sourceware.org/ml/libc-hacker/2006-09/msg00008.html
-                     This test needs valgrind to catch the bug on Debian
-                     GNU/Linux 3.1 x86, but it might catch the bug better
-                     on other platforms and it shouldn't hurt to try the
-                     test here.  */
-                  static char const pat[] = "insert into";
-                  static char const data[] =
-                    "\xFF\0\x12\xA2\xAA\xC4\xB1,K\x12\xC4\xB1*\xACK";
-                  re_set_syntax (RE_SYNTAX_GREP | RE_HAT_LISTS_NOT_NEWLINE
-                                 | RE_ICASE);
-                  memset (&regex, 0, sizeof regex);
-                  s = re_compile_pattern (pat, sizeof pat - 1, &regex);
-                  if (s)
-                    result |= 1;
-                  else
-                    {
-                      if (re_search (&regex, data, sizeof data - 1,
-                                     0, sizeof data - 1, &regs)
-                          != -1)
-                        result |= 1;
-                      regfree (&regex);
-                    }
-                }
 
-                {
-                  /* This test is from glibc bug 15078.
-                     The test case is from Andreas Schwab in
-                     <https://sourceware.org/ml/libc-alpha/2013-01/msg00967.html>.
-                     */
-                  static char const pat[] = "[^x]x";
-                  static char const data[] =
-                    /* <U1000><U103B><U103D><U1014><U103A><U102F><U1015><U103A> */
-                    "\xe1\x80\x80"
-                    "\xe1\x80\xbb"
-                    "\xe1\x80\xbd"
-                    "\xe1\x80\x94"
-                    "\xe1\x80\xba"
-                    "\xe1\x80\xaf"
-                    "\xe1\x80\x95"
-                    "\xe1\x80\xba"
-                    "x";
-                  re_set_syntax (0);
-                  memset (&regex, 0, sizeof regex);
-                  s = re_compile_pattern (pat, sizeof pat - 1, &regex);
-                  if (s)
-                    result |= 1;
-                  else
-                    {
-                      i = re_search (&regex, data, sizeof data - 1,
-                                     0, sizeof data - 1, 0);
-                      if (i != 0 && i != 21)
-                        result |= 1;
-                      regfree (&regex);
-                    }
-                }
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_frexpl_works" >&5
+printf "%s\n" "$gl_cv_func_frexpl_works" >&6; }
 
-                if (! setlocale (LC_ALL, "C"))
-                  return 1;
-              }
+    case "$gl_cv_func_frexpl_works" in
+      *yes) gl_func_frexpl_no_libm=yes ;;
+      *)    gl_func_frexpl_no_libm=no; REPLACE_FREXPL=1 ;;
+    esac
+  else
+    gl_func_frexpl_no_libm=no
+        REPLACE_FREXPL=1
+  fi
+  if test $gl_func_frexpl_no_libm = yes; then
 
-            /* This test is from glibc bug 3957, reported by Andrew Mackey.  */
-            re_set_syntax (RE_SYNTAX_EGREP | RE_HAT_LISTS_NOT_NEWLINE);
-            memset (&regex, 0, sizeof regex);
-            s = re_compile_pattern ("a[^x]b", 6, &regex);
-            if (s)
-              result |= 2;
-            else
-              {
-                /* This should fail, but succeeds for glibc-2.5.  */
-                if (re_search (&regex, "a\nb", 3, 0, 3, &regs) != -1)
-                  result |= 2;
-                regfree (&regex);
-              }
+printf "%s\n" "#define HAVE_FREXPL_IN_LIBC 1" >>confdefs.h
 
-            /* This regular expression is from Spencer ere test number 75
-               in grep-2.3.  */
-            re_set_syntax (RE_SYNTAX_POSIX_EGREP);
-            memset (&regex, 0, sizeof regex);
-            for (i = 0; i <= UCHAR_MAX; i++)
-              folded_chars[i] = i;
-            regex.translate = folded_chars;
-            s = re_compile_pattern ("a[[:]:]]b\n", 11, &regex);
-            /* This should fail with _Invalid character class name_ error.  */
-            if (!s)
-              {
-                result |= 4;
-                regfree (&regex);
-              }
+            ac_fn_check_decl "$LINENO" "frexpl" "ac_cv_have_decl_frexpl" "#include <math.h>
+" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_frexpl" = xyes
+then :
 
-            /* Ensure that [b-a] is diagnosed as invalid, when
-               using RE_NO_EMPTY_RANGES. */
-            re_set_syntax (RE_SYNTAX_POSIX_EGREP | RE_NO_EMPTY_RANGES);
-            memset (&regex, 0, sizeof regex);
-            s = re_compile_pattern ("a[b-a]", 6, &regex);
-            if (s == 0)
-              {
-                result |= 8;
-                regfree (&regex);
-              }
+else $as_nop
+  HAVE_DECL_FREXPL=0
+fi
+  fi
 
-            /* This should succeed, but does not for glibc-2.1.3.  */
-            memset (&regex, 0, sizeof regex);
-            s = re_compile_pattern ("{1", 2, &regex);
-            if (s)
-              result |= 8;
-            else
-              regfree (&regex);
 
-            /* The following example is derived from a problem report
-               against gawk from Jorge Stolfi <stolfi@ic.unicamp.br>.  */
-            memset (&regex, 0, sizeof regex);
-            s = re_compile_pattern ("[an\371]*n", 7, &regex);
-            if (s)
-              result |= 8;
-            else
-              {
-                /* This should match, but does not for glibc-2.2.1.  */
-                if (re_match (&regex, "an", 2, 0, &regs) != 2)
-                  result |= 8;
-                else
-                  {
-                    free (regs.start);
-                    free (regs.end);
-                  }
-                regfree (&regex);
-              }
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ldexpl() can be used without linking with libm" >&5
+printf %s "checking whether ldexpl() can be used without linking with libm... " >&6; }
+if test ${gl_cv_func_ldexpl_no_libm+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+
+      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <math.h>
+             long double x;
+int
+main (void)
+{
+return ldexpl (x, -1) > 0;
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"
+then :
+  gl_cv_func_ldexpl_no_libm=yes
+else $as_nop
+  gl_cv_func_ldexpl_no_libm=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
 
-            memset (&regex, 0, sizeof regex);
-            s = re_compile_pattern ("x", 1, &regex);
-            if (s)
-              result |= 8;
-            else
-              {
-                /* glibc-2.2.93 does not work with a negative RANGE argument.  */
-                if (re_search (&regex, "wxy", 3, 2, -2, &regs) != 1)
-                  result |= 8;
-                else
-                  {
-                    free (regs.start);
-                    free (regs.end);
-                  }
-                regfree (&regex);
-              }
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ldexpl_no_libm" >&5
+printf "%s\n" "$gl_cv_func_ldexpl_no_libm" >&6; }
 
-            /* The version of regex.c in older versions of gnulib
-               ignored RE_ICASE.  Detect that problem too.  */
-            re_set_syntax (RE_SYNTAX_EMACS | RE_ICASE);
-            memset (&regex, 0, sizeof regex);
-            s = re_compile_pattern ("x", 1, &regex);
-            if (s)
-              result |= 16;
-            else
-              {
-                if (re_search (&regex, "WXY", 3, 0, 3, &regs) < 0)
-                  result |= 16;
-                else
-                  {
-                    free (regs.start);
-                    free (regs.end);
-                  }
-                regfree (&regex);
-              }
+  if test $gl_cv_func_ldexpl_no_libm = yes; then
 
-            /* Catch a bug reported by Vin Shelton in
-               https://lists.gnu.org/r/bug-coreutils/2007-06/msg00089.html
-               */
-            re_set_syntax (RE_SYNTAX_POSIX_BASIC
-                           & ~RE_CONTEXT_INVALID_DUP
-                           & ~RE_NO_EMPTY_RANGES);
-            memset (&regex, 0, sizeof regex);
-            s = re_compile_pattern ("[[:alnum:]_-]\\\\+$", 16, &regex);
-            if (s)
-              result |= 32;
-            else
-              regfree (&regex);
 
-            /* REG_STARTEND was added to glibc on 2004-01-15.
-               Reject older versions.  */
-            if (! REG_STARTEND)
-              result |= 64;
+     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether ldexpl works" >&5
+printf %s "checking whether ldexpl works... " >&6; }
+if test ${gl_cv_func_ldexpl_works+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
-            /* Matching with the compiled form of this regexp would provoke
-               an assertion failure prior to glibc-2.28:
-                 regexec.c:1375: pop_fail_stack: Assertion 'num >= 0' failed
-               With glibc-2.28, compilation fails and reports the invalid
-               back reference.  */
-            re_set_syntax (RE_SYNTAX_POSIX_EGREP);
-            memset (&regex, 0, sizeof regex);
-            s = re_compile_pattern ("0|()0|\\1|0", 10, &regex);
-            if (!s)
-              result |= 64;
-            else
-              {
-                if (strcmp (s, "Invalid back reference"))
-                  result |= 64;
-                regfree (&regex);
-              }
+      if test "$cross_compiling" = yes
+then :
 
-#if 0
-            /* It would be nice to reject hosts whose regoff_t values are too
-               narrow (including glibc on hosts with 64-bit ptrdiff_t and
-               32-bit int), but we should wait until glibc implements this
-               feature.  Otherwise, support for equivalence classes and
-               multibyte collation symbols would always be broken except
-               when compiling --without-included-regex.   */
-            if (sizeof (regoff_t) < sizeof (ptrdiff_t)
-                || sizeof (regoff_t) < sizeof (ssize_t))
-              result |= 64;
-#endif
+         case "$host_os" in
+           aix | aix[3-6]*) gl_cv_func_ldexpl_works="guessing no" ;;
+                            # Guess yes on native Windows.
+           mingw*)          gl_cv_func_ldexpl_works="guessing yes" ;;
+           *)               gl_cv_func_ldexpl_works="guessing yes" ;;
+         esac
 
-            return result;
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
-  ;
-  return 0;
+#include <math.h>
+extern
+#ifdef __cplusplus
+"C"
+#endif
+long double ldexpl (long double, int);
+int main()
+{
+  int result = 0;
+  {
+    volatile long double x = 1.0;
+    volatile long double y = ldexpl (x, -1);
+    if (y != 0.5L)
+      result |= 1;
+  }
+  {
+    volatile long double x = 1.73205L;
+    volatile long double y = ldexpl (x, 0);
+    if (y != x)
+      result |= 2;
+  }
+  return result;
 }
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_func_re_compile_pattern_working=yes
+  gl_cv_func_ldexpl_works=yes
 else $as_nop
-  gl_cv_func_re_compile_pattern_working=no
+  gl_cv_func_ldexpl_works=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
@@ -43686,72 +43401,119 @@
 
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_re_compile_pattern_working" >&5
-printf "%s\n" "$gl_cv_func_re_compile_pattern_working" >&6; }
-    case "$gl_cv_func_re_compile_pattern_working" in #(
-      *yes) ac_use_included_regex=no;; #(
-      *no) ac_use_included_regex=yes;;
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_ldexpl_works" >&5
+printf "%s\n" "$gl_cv_func_ldexpl_works" >&6; }
+
+    case "$gl_cv_func_ldexpl_works" in
+      *yes)
+
+printf "%s\n" "#define HAVE_LDEXPL_IN_LIBC 1" >>confdefs.h
+
+                        ac_fn_check_decl "$LINENO" "ldexpl" "ac_cv_have_decl_ldexpl" "#include <math.h>
+" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_ldexpl" = xyes
+then :
+
+else $as_nop
+  HAVE_DECL_LDEXPL=0
+fi
+        ;;
     esac
-    ;;
-  *) as_fn_error $? "Invalid value for --with-included-regex: $with_included_regex" "$LINENO" 5
-    ;;
-  esac
+  fi
 
-  if test $ac_use_included_regex = yes; then
 
-printf "%s\n" "#define _REGEX_INCLUDE_LIMITS_H 1" >>confdefs.h
+  ac_fn_check_decl "$LINENO" "program_invocation_name" "ac_cv_have_decl_program_invocation_name" "#include <errno.h>
+" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_program_invocation_name" = xyes
+then :
+  ac_have_decl=1
+else $as_nop
+  ac_have_decl=0
+fi
+printf "%s\n" "#define HAVE_DECL_PROGRAM_INVOCATION_NAME $ac_have_decl" >>confdefs.h
 
+  ac_fn_check_decl "$LINENO" "program_invocation_short_name" "ac_cv_have_decl_program_invocation_short_name" "#include <errno.h>
+" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_program_invocation_short_name" = xyes
+then :
+  ac_have_decl=1
+else $as_nop
+  ac_have_decl=0
+fi
+printf "%s\n" "#define HAVE_DECL_PROGRAM_INVOCATION_SHORT_NAME $ac_have_decl" >>confdefs.h
 
-printf "%s\n" "#define _REGEX_LARGE_OFFSETS 1" >>confdefs.h
 
 
-printf "%s\n" "#define re_syntax_options rpl_re_syntax_options" >>confdefs.h
+  XGETTEXT_EXTRA_OPTIONS="$XGETTEXT_EXTRA_OPTIONS --keyword='proper_name:1,\"This is a proper name. See the gettext manual, section Names.\"'"
 
 
-printf "%s\n" "#define re_set_syntax rpl_re_set_syntax" >>confdefs.h
 
+  XGETTEXT_EXTRA_OPTIONS="$XGETTEXT_EXTRA_OPTIONS --keyword='proper_name_utf8:1,\"This is a proper name. See the gettext manual, section Names.\"'"
 
-printf "%s\n" "#define re_compile_pattern rpl_re_compile_pattern" >>confdefs.h
 
 
-printf "%s\n" "#define re_compile_fastmap rpl_re_compile_fastmap" >>confdefs.h
+  :
 
 
-printf "%s\n" "#define re_search rpl_re_search" >>confdefs.h
 
 
-printf "%s\n" "#define re_search_2 rpl_re_search_2" >>confdefs.h
+  ac_fn_c_check_func "$LINENO" "raise" "ac_cv_func_raise"
+if test "x$ac_cv_func_raise" = xyes
+then :
+  printf "%s\n" "#define HAVE_RAISE 1" >>confdefs.h
 
+fi
 
-printf "%s\n" "#define re_match rpl_re_match" >>confdefs.h
+  if test $ac_cv_func_raise = no; then
+    HAVE_RAISE=0
+  else
 
 
-printf "%s\n" "#define re_match_2 rpl_re_match_2" >>confdefs.h
+      if test $HAVE_MSVC_INVALID_PARAMETER_HANDLER = 1; then
+        REPLACE_RAISE=1
+      fi
 
 
-printf "%s\n" "#define re_set_registers rpl_re_set_registers" >>confdefs.h
 
 
-printf "%s\n" "#define re_comp rpl_re_comp" >>confdefs.h
 
+  HAVE_POSIX_SIGNALBLOCKING=0
+  if test "$gl_cv_type_sigset_t" = yes; then
+    ac_fn_c_check_func "$LINENO" "sigprocmask" "ac_cv_func_sigprocmask"
+if test "x$ac_cv_func_sigprocmask" = xyes
+then :
+  HAVE_POSIX_SIGNALBLOCKING=1
+fi
 
-printf "%s\n" "#define re_exec rpl_re_exec" >>confdefs.h
+  fi
 
+      if test $HAVE_POSIX_SIGNALBLOCKING = 0; then
 
-printf "%s\n" "#define regcomp rpl_regcomp" >>confdefs.h
 
 
-printf "%s\n" "#define regexec rpl_regexec" >>confdefs.h
+
+          if test $gl_cv_header_signal_h_SIGPIPE != yes; then
+            REPLACE_RAISE=1
+          fi
+
+      fi
+
+  fi
+
+  if test $HAVE_RAISE = 0 || test $REPLACE_RAISE = 1; then
 
 
-printf "%s\n" "#define regerror rpl_regerror" >>confdefs.h
 
 
-printf "%s\n" "#define regfree rpl_regfree" >>confdefs.h
 
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS raise.$ac_objext"
+
+    :
   fi
 
-  if test $ac_use_included_regex = yes; then
 
 
 
@@ -43760,357 +43522,372 @@
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS regex.$ac_objext"
+          GL_M4_GNULIB_RAISE=1
 
 
 
 
 
+printf "%s\n" "#define GNULIB_TEST_RAISE 1" >>confdefs.h
 
 
-  ac_fn_c_check_header_compile "$LINENO" "libintl.h" "ac_cv_header_libintl_h" "$ac_includes_default"
-if test "x$ac_cv_header_libintl_h" = xyes
+
+
+
+
+
+  ac_fn_c_check_func "$LINENO" "rawmemchr" "ac_cv_func_rawmemchr"
+if test "x$ac_cv_func_rawmemchr" = xyes
 then :
-  printf "%s\n" "#define HAVE_LIBINTL_H 1" >>confdefs.h
+  printf "%s\n" "#define HAVE_RAWMEMCHR 1" >>confdefs.h
 
 fi
 
+  if test $ac_cv_func_rawmemchr = no; then
+    HAVE_RAWMEMCHR=0
+  fi
+
+  if test $HAVE_RAWMEMCHR = 0; then
 
-  ac_fn_check_decl "$LINENO" "isblank" "ac_cv_have_decl_isblank" "#include <ctype.h>
-" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_isblank" = xyes
+
+
+
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS rawmemchr.$ac_objext"
+
+    :
+  fi
+
+
+
+
+
+
+
+
+
+          GL_M4_GNULIB_RAWMEMCHR=1
+
+
+
+
+
+printf "%s\n" "#define GNULIB_TEST_RAWMEMCHR 1" >>confdefs.h
+
+
+
+
+
+
+  ac_fn_c_check_func "$LINENO" "readdir" "ac_cv_func_readdir"
+if test "x$ac_cv_func_readdir" = xyes
 then :
-  ac_have_decl=1
-else $as_nop
-  ac_have_decl=0
+  printf "%s\n" "#define HAVE_READDIR 1" >>confdefs.h
+
 fi
-printf "%s\n" "#define HAVE_DECL_ISBLANK $ac_have_decl" >>confdefs.h
+
+  if test $ac_cv_func_readdir = no; then
+    HAVE_READDIR=0
+  fi
+
+  if test $HAVE_READDIR = 0; then
+
+
+
+
 
 
+
+
+  M4_LIBOBJS="$M4_LIBOBJS readdir.$ac_objext"
+
   fi
 
 
 
 
 
-                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether rename honors trailing slash on destination" >&5
-printf %s "checking whether rename honors trailing slash on destination... " >&6; }
-if test ${gl_cv_func_rename_slash_dst_works+y}
+
+
+
+
+          GL_M4_GNULIB_READDIR=1
+
+
+
+
+
+printf "%s\n" "#define GNULIB_TEST_READDIR 1" >>confdefs.h
+
+
+
+
+
+
+  if test $ac_cv_func_readlink = no; then
+    HAVE_READLINK=0
+  else
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether readlink signature is correct" >&5
+printf %s "checking whether readlink signature is correct... " >&6; }
+if test ${gl_cv_decl_readlink_works+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  rm -rf conftest.f conftest.f1 conftest.f2 conftest.d1 conftest.d2 conftest.lnk
-    touch conftest.f && touch conftest.f1 && mkdir conftest.d1 ||
-      as_fn_error $? "cannot create temporary files" "$LINENO" 5
-    # Assume that if we have lstat, we can also check symlinks.
-    if test $ac_cv_func_lstat = yes; then
-      ln -s conftest.f conftest.lnk
-    fi
-    if test "$cross_compiling" = yes
-then :
-        case "$host_os" in
-                          # Guess yes on Linux systems.
-         linux-* | linux) gl_cv_func_rename_slash_dst_works="guessing yes" ;;
-                          # Guess yes on glibc systems.
-         *-gnu*)          gl_cv_func_rename_slash_dst_works="guessing yes" ;;
-                          # Guess no on native Windows.
-         mingw*)          gl_cv_func_rename_slash_dst_works="guessing no" ;;
-                          # If we don't know, obey --enable-cross-guesses.
-         *)               gl_cv_func_rename_slash_dst_works="$gl_cross_guess_normal" ;;
-       esac
-
-else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-
-#        include <stdio.h>
-#        include <stdlib.h>
-
+#include <unistd.h>
+      /* Cause compilation failure if original declaration has wrong type.  */
+      ssize_t readlink (const char *, char *, size_t);
 int
 main (void)
 {
-int result = 0;
-           if (rename ("conftest.f1", "conftest.f2/") == 0)
-             result |= 1;
-           if (rename ("conftest.d1", "conftest.d2/") != 0)
-             result |= 2;
-#if HAVE_LSTAT
-           if (rename ("conftest.f", "conftest.lnk/") == 0)
-             result |= 4;
-#endif
-           return result;
 
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_run "$LINENO"
+if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_func_rename_slash_dst_works=yes
+  gl_cv_decl_readlink_works=yes
 else $as_nop
-  gl_cv_func_rename_slash_dst_works=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
+  gl_cv_decl_readlink_works=no
 fi
-
-    rm -rf conftest.f conftest.f1 conftest.f2 conftest.d1 conftest.d2 conftest.lnk
-
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_rename_slash_dst_works" >&5
-printf "%s\n" "$gl_cv_func_rename_slash_dst_works" >&6; }
-  case "$gl_cv_func_rename_slash_dst_works" in
-    *yes) ;;
-    *)
-      REPLACE_RENAME=1
-
-printf "%s\n" "#define RENAME_TRAILING_SLASH_DEST_BUG 1" >>confdefs.h
-
-      ;;
-  esac
-
-            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether rename honors trailing slash on source" >&5
-printf %s "checking whether rename honors trailing slash on source... " >&6; }
-if test ${gl_cv_func_rename_slash_src_works+y}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_decl_readlink_works" >&5
+printf "%s\n" "$gl_cv_decl_readlink_works" >&6; }
+            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether readlink handles trailing slash correctly" >&5
+printf %s "checking whether readlink handles trailing slash correctly... " >&6; }
+if test ${gl_cv_func_readlink_trailing_slash+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  rm -rf conftest.f conftest.f1 conftest.d1 conftest.d2 conftest.d3 conftest.lnk
-    touch conftest.f && touch conftest.f1 && mkdir conftest.d1 ||
-      as_fn_error $? "cannot create temporary files" "$LINENO" 5
-    # Assume that if we have lstat, we can also check symlinks.
-    if test $ac_cv_func_lstat = yes; then
-      ln -s conftest.f conftest.lnk
-    fi
-    if test "$cross_compiling" = yes
+  # We have readlink, so assume ln -s works.
+       ln -s conftest.no-such conftest.link
+       ln -s conftest.link conftest.lnk2
+       if test "$cross_compiling" = yes
 then :
-        case "$host_os" in
-                          # Guess yes on Linux systems.
-         linux-* | linux) gl_cv_func_rename_slash_src_works="guessing yes" ;;
-                          # Guess yes on glibc systems.
-         *-gnu*)          gl_cv_func_rename_slash_src_works="guessing yes" ;;
-                          # Guess yes on native Windows.
-         mingw*)          gl_cv_func_rename_slash_src_works="guessing yes" ;;
-                          # If we don't know, obey --enable-cross-guesses.
-         *)               gl_cv_func_rename_slash_src_works="$gl_cross_guess_normal" ;;
-       esac
+  case "$host_os" in
+            # Guess yes on Linux or glibc systems.
+            linux-* | linux | *-gnu* | gnu*)
+              gl_cv_func_readlink_trailing_slash="guessing yes" ;;
+            # Guess no on AIX or HP-UX.
+            aix* | hpux*)
+              gl_cv_func_readlink_trailing_slash="guessing no" ;;
+            # If we don't know, obey --enable-cross-guesses.
+            *)
+              gl_cv_func_readlink_trailing_slash="$gl_cross_guess_normal" ;;
+          esac
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-
-#        include <stdio.h>
-#        include <stdlib.h>
+#include <unistd.h>
 
 int
 main (void)
 {
-int result = 0;
-           if (rename ("conftest.f1/", "conftest.d3") == 0)
-             result |= 1;
-           if (rename ("conftest.d1/", "conftest.d2") != 0)
-             result |= 2;
-#if HAVE_LSTAT
-           if (rename ("conftest.lnk/", "conftest.f") == 0)
-             result |= 4;
-#endif
-           return result;
-
+char buf[20];
+      return readlink ("conftest.lnk2/", buf, sizeof buf) != -1;
   ;
   return 0;
 }
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_func_rename_slash_src_works=yes
+  gl_cv_func_readlink_trailing_slash=yes
 else $as_nop
-  gl_cv_func_rename_slash_src_works=no
+  gl_cv_func_readlink_trailing_slash=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
-    rm -rf conftest.f conftest.f1 conftest.d1 conftest.d2 conftest.d3 conftest.lnk
-
+      rm -f conftest.link conftest.lnk2
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_rename_slash_src_works" >&5
-printf "%s\n" "$gl_cv_func_rename_slash_src_works" >&6; }
-  case "$gl_cv_func_rename_slash_src_works" in
-    *yes) ;;
-    *)
-      REPLACE_RENAME=1
-
-printf "%s\n" "#define RENAME_TRAILING_SLASH_SOURCE_BUG 1" >>confdefs.h
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_readlink_trailing_slash" >&5
+printf "%s\n" "$gl_cv_func_readlink_trailing_slash" >&6; }
+    case "$gl_cv_func_readlink_trailing_slash" in
+      *yes)
+        if test "$gl_cv_decl_readlink_works" != yes; then
+          REPLACE_READLINK=1
+        fi
+        ;;
+      *)
 
-      ;;
-  esac
+printf "%s\n" "#define READLINK_TRAILING_SLASH_BUG 1" >>confdefs.h
 
+        REPLACE_READLINK=1
+        ;;
+    esac
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether rename manages hard links correctly" >&5
-printf %s "checking whether rename manages hard links correctly... " >&6; }
-if test ${gl_cv_func_rename_link_works+y}
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether readlink truncates results correctly" >&5
+printf %s "checking whether readlink truncates results correctly... " >&6; }
+if test ${gl_cv_func_readlink_truncate+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  if test $ac_cv_func_link = yes; then
-       if test $cross_compiling != yes; then
-         rm -rf conftest.f conftest.f1 conftest.f2
-         if touch conftest.f conftest.f2 && ln conftest.f conftest.f1 &&
-             set x `ls -i conftest.f conftest.f1` && test "" = ""; then
-           if test "$cross_compiling" = yes
+  # We have readlink, so assume ln -s works.
+       ln -s ab conftest.link
+       if test "$cross_compiling" = yes
 then :
-                :
+  case "$host_os" in
+            # Guess yes on Linux or glibc systems.
+            linux-* | linux | *-gnu* | gnu*)
+              gl_cv_func_readlink_truncate="guessing yes" ;;
+            # Guess no on AIX or HP-UX.
+            aix* | hpux*)
+              gl_cv_func_readlink_truncate="guessing no" ;;
+            # If we don't know, obey --enable-cross-guesses.
+            *)
+              gl_cv_func_readlink_truncate="$gl_cross_guess_normal" ;;
+          esac
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-
-#               include <errno.h>
-#               include <stdio.h>
-#               include <stdlib.h>
-#               include <unistd.h>
-
-
-$gl_mda_defines
+#include <unistd.h>
 
 int
 main (void)
 {
-int result = 0;
-                  if (rename ("conftest.f", "conftest.f1"))
-                    result |= 1;
-                  if (unlink ("conftest.f1"))
-                    result |= 2;
-
-                  /* Allow either the POSIX-required behavior, where the
-                     previous rename kept conftest.f, or the (better) NetBSD
-                     behavior, where it removed conftest.f.  */
-                  if (rename ("conftest.f", "conftest.f") != 0
-                      && errno != ENOENT)
-                    result |= 4;
-
-                  if (rename ("conftest.f1", "conftest.f1") == 0)
-                    result |= 8;
-                  if (rename ("conftest.f2", "conftest.f2") != 0)
-                    result |= 16;
-                  return result;
-
+char c;
+      return readlink ("conftest.link", &c, 1) != 1;
   ;
   return 0;
 }
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_func_rename_link_works=yes
+  gl_cv_func_readlink_truncate=yes
 else $as_nop
-  gl_cv_func_rename_link_works=no
+  gl_cv_func_readlink_truncate=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
-         else
-           gl_cv_func_rename_link_works="guessing no"
-         fi
-         rm -rf conftest.f conftest.f1 conftest.f2
-       else
-                  case "$host_os" in
-                            # Guess yes on Linux systems.
-           linux-* | linux) gl_cv_func_rename_link_works="guessing yes" ;;
-                            # Guess yes on glibc systems.
-           *-gnu*)          gl_cv_func_rename_link_works="guessing yes" ;;
-                            # Guess yes on native Windows.
-           mingw*)          gl_cv_func_rename_link_works="guessing yes" ;;
-                            # If we don't know, obey --enable-cross-guesses.
-           *)               gl_cv_func_rename_link_works="$gl_cross_guess_normal" ;;
-         esac
-       fi
-     else
-       gl_cv_func_rename_link_works=yes
-     fi
-
+      rm -f conftest.link conftest.lnk2
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_rename_link_works" >&5
-printf "%s\n" "$gl_cv_func_rename_link_works" >&6; }
-  case "$gl_cv_func_rename_link_works" in
-    *yes) ;;
-    *)
-      REPLACE_RENAME=1
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_readlink_truncate" >&5
+printf "%s\n" "$gl_cv_func_readlink_truncate" >&6; }
+    case $gl_cv_func_readlink_truncate in
+      *yes)
+        if test "$gl_cv_decl_readlink_works" != yes; then
+          REPLACE_READLINK=1
+        fi
+        ;;
+      *)
 
-printf "%s\n" "#define RENAME_HARD_LINK_BUG 1" >>confdefs.h
+printf "%s\n" "#define READLINK_TRUNCATE_BUG 1" >>confdefs.h
 
-      ;;
-  esac
+        REPLACE_READLINK=1
+        ;;
+    esac
+  fi
 
-          { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether rename manages existing destinations correctly" >&5
-printf %s "checking whether rename manages existing destinations correctly... " >&6; }
-if test ${gl_cv_func_rename_dest_works+y}
+  if test $HAVE_READLINK = 0 || test $REPLACE_READLINK = 1; then
+
+
+
+
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS readlink.$ac_objext"
+
+
+  :
+
+  fi
+
+
+
+
+
+
+
+
+
+          GL_M4_GNULIB_READLINK=1
+
+
+
+
+
+printf "%s\n" "#define GNULIB_TEST_READLINK 1" >>confdefs.h
+
+
+
+
+
+
+  if test $REPLACE_REALLOC = 0; then
+
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether realloc (0, 0) returns nonnull" >&5
+printf %s "checking whether realloc (0, 0) returns nonnull... " >&6; }
+if test ${ac_cv_func_realloc_0_nonnull+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  rm -rf conftest.f conftest.d1 conftest.d2
-    touch conftest.f && mkdir conftest.d1 conftest.d2 ||
-      as_fn_error $? "cannot create temporary files" "$LINENO" 5
-    if test "$cross_compiling" = yes
+  if test "$cross_compiling" = yes
 then :
-        case "$host_os" in
-                          # Guess yes on Linux systems.
-         linux-* | linux) gl_cv_func_rename_dest_works="guessing yes" ;;
-                          # Guess yes on glibc systems.
-         *-gnu*)          gl_cv_func_rename_dest_works="guessing yes" ;;
-                          # Guess no on native Windows.
-         mingw*)          gl_cv_func_rename_dest_works="guessing no" ;;
-                          # If we don't know, obey --enable-cross-guesses.
-         *)               gl_cv_func_rename_dest_works="$gl_cross_guess_normal" ;;
-       esac
+  case "$host_os" in
+          # Guess yes on platforms where we know the result.
+          *-gnu* | freebsd* | netbsd* | openbsd* | bitrig* \
+          | gnu* | *-musl* | midnightbsd* \
+          | hpux* | solaris* | cygwin* | mingw* | msys* )
+            ac_cv_func_realloc_0_nonnull="guessing yes" ;;
+          # If we don't know, obey --enable-cross-guesses.
+          *) ac_cv_func_realloc_0_nonnull="$gl_cross_guess_normal" ;;
+        esac
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-
-#        include <stdio.h>
-#        include <stdlib.h>
+#include <stdlib.h>
 
 int
 main (void)
 {
-int result = 0;
-           if (rename ("conftest.d1", "conftest.d2") != 0)
-             result |= 1;
-           if (rename ("conftest.d2", "conftest.f") == 0)
-             result |= 2;
-           return result;
-
+void *p = realloc (0, 0);
+            int result = !p;
+            free (p);
+            return result;
   ;
   return 0;
 }
+
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_func_rename_dest_works=yes
+  ac_cv_func_realloc_0_nonnull=yes
 else $as_nop
-  gl_cv_func_rename_dest_works=no
+  ac_cv_func_realloc_0_nonnull=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
-    rm -rf conftest.f conftest.d1 conftest.d2
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_rename_dest_works" >&5
-printf "%s\n" "$gl_cv_func_rename_dest_works" >&6; }
-  case "$gl_cv_func_rename_dest_works" in
-    *yes) ;;
-    *)
-      REPLACE_RENAME=1
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_realloc_0_nonnull" >&5
+printf "%s\n" "$ac_cv_func_realloc_0_nonnull" >&6; }
+  case $ac_cv_func_realloc_0_nonnull in #(
+  *yes) :
+     ;; #(
+  *) :
+    REPLACE_REALLOC=1 ;;
+esac
 
-printf "%s\n" "#define RENAME_DEST_EXISTS_BUG 1" >>confdefs.h
+  fi
 
-      ;;
-  esac
+  if test $REPLACE_REALLOC = 1; then
 
-  if test $REPLACE_RENAME = 1; then
 
 
 
@@ -44118,11 +43895,17 @@
 
 
 
+  M4_LIBOBJS="$M4_LIBOBJS realloc.$ac_objext"
+
+  fi
 
-  M4_LIBOBJS="$M4_LIBOBJS rename.$ac_objext"
 
+
+  if test $REPLACE_MALLOC = 1; then
+    REPLACE_REALLOC=1
   fi
 
+  if test $REPLACE_REALLOC = 1; then
 
 
 
@@ -44131,31 +43914,47 @@
 
 
 
-          GL_M4_GNULIB_RENAME=1
+  M4_LIBOBJS="$M4_LIBOBJS realloc.$ac_objext"
 
+  fi
 
 
 
 
-printf "%s\n" "#define GNULIB_TEST_RENAME 1" >>confdefs.h
 
 
 
 
 
+          GL_M4_GNULIB_REALLOC_POSIX=1
 
-  ac_fn_c_check_func "$LINENO" "rewinddir" "ac_cv_func_rewinddir"
-if test "x$ac_cv_func_rewinddir" = xyes
+
+
+
+
+printf "%s\n" "#define GNULIB_TEST_REALLOC_POSIX 1" >>confdefs.h
+
+
+
+
+
+
+
+
+  ac_fn_c_check_func "$LINENO" "reallocarray" "ac_cv_func_reallocarray"
+if test "x$ac_cv_func_reallocarray" = xyes
 then :
-  printf "%s\n" "#define HAVE_REWINDDIR 1" >>confdefs.h
+  printf "%s\n" "#define HAVE_REALLOCARRAY 1" >>confdefs.h
 
 fi
 
-  if test $ac_cv_func_rewinddir = no; then
-    HAVE_REWINDDIR=0
+  if test "$ac_cv_func_reallocarray" = no; then
+    HAVE_REALLOCARRAY=0
+  elif test "$gl_cv_malloc_ptrdiff" = no; then
+    REPLACE_REALLOCARRAY=1
   fi
 
-  if test $HAVE_REWINDDIR = 0; then
+  if test $HAVE_REALLOCARRAY = 0 || test $REPLACE_REALLOCARRAY = 1; then
 
 
 
@@ -44164,11 +43963,14 @@
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS rewinddir.$ac_objext"
+  M4_LIBOBJS="$M4_LIBOBJS reallocarray.$ac_objext"
 
+    :
   fi
 
 
+printf "%s\n" "#define GNULIB_REALLOCARRAY 1" >>confdefs.h
+
 
 
 
@@ -44176,65 +43978,312 @@
 
 
 
-          GL_M4_GNULIB_REWINDDIR=1
 
 
 
+          GL_M4_GNULIB_REALLOCARRAY=1
 
 
-printf "%s\n" "#define GNULIB_TEST_REWINDDIR 1" >>confdefs.h
 
 
 
+printf "%s\n" "#define GNULIB_TEST_REALLOCARRAY 1" >>confdefs.h
 
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether rmdir works" >&5
-printf %s "checking whether rmdir works... " >&6; }
-if test ${gl_cv_func_rmdir_works+y}
+
+
+# Check whether --with-included-regex was given.
+if test ${with_included_regex+y}
+then :
+  withval=$with_included_regex;
+fi
+
+
+  case $with_included_regex in #(
+  yes|no) ac_use_included_regex=$with_included_regex
+        ;;
+  '')
+    # If the system regex support is good enough that it passes the
+    # following run test, then default to *not* using the included regex.c.
+    # If cross compiling, assume the test would fail and use the included
+    # regex.c.
+
+
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for working re_compile_pattern" >&5
+printf %s "checking for working re_compile_pattern... " >&6; }
+if test ${gl_cv_func_re_compile_pattern_working+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  mkdir conftest.dir
-     touch conftest.file
-     if test "$cross_compiling" = yes
+  if test "$cross_compiling" = yes
 then :
   case "$host_os" in
-                           # Guess yes on Linux systems.
-          linux-* | linux) gl_cv_func_rmdir_works="guessing yes" ;;
-                           # Guess yes on glibc systems.
-          *-gnu* | gnu*)   gl_cv_func_rmdir_works="guessing yes" ;;
-                           # Guess no on native Windows.
-          mingw*)          gl_cv_func_rmdir_works="guessing no" ;;
-                           # If we don't know, obey --enable-cross-guesses.
-          *)               gl_cv_func_rmdir_works="$gl_cross_guess_normal" ;;
-        esac
+                   # Guess no on native Windows.
+           mingw*) gl_cv_func_re_compile_pattern_working="guessing no" ;;
+                   # Otherwise obey --enable-cross-guesses.
+           *)      gl_cv_func_re_compile_pattern_working="$gl_cross_guess_normal" ;;
+         esac
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <stdio.h>
-           #include <errno.h>
-           #if HAVE_UNISTD_H
-           # include <unistd.h>
-           #else /* on Windows with MSVC */
-           # include <direct.h>
-           #endif
+#include <regex.h>
+
+            #include <locale.h>
+            #include <limits.h>
+            #include <string.h>
+
+            #if defined M_CHECK_ACTION || HAVE_DECL_ALARM
+            # include <signal.h>
+            # include <unistd.h>
+            #endif
+
+            #if HAVE_MALLOC_H
+            # include <malloc.h>
+            #endif
+
+            #ifdef M_CHECK_ACTION
+            /* Exit with distinguishable exit code.  */
+            static void sigabrt_no_core (int sig) { raise (SIGTERM); }
+            #endif
+
+int
+main (void)
+{
+int result = 0;
+            static struct re_pattern_buffer regex;
+            unsigned char folded_chars[UCHAR_MAX + 1];
+            int i;
+            const char *s;
+            struct re_registers regs;
+
+            /* Some builds of glibc go into an infinite loop on this
+               test.  Use alarm to force death, and mallopt to avoid
+               malloc recursion in diagnosing the corrupted heap. */
+#if HAVE_DECL_ALARM
+            signal (SIGALRM, SIG_DFL);
+            alarm (2);
+#endif
+#ifdef M_CHECK_ACTION
+            signal (SIGABRT, sigabrt_no_core);
+            mallopt (M_CHECK_ACTION, 2);
+#endif
+
+            if (setlocale (LC_ALL, "en_US.UTF-8"))
+              {
+                {
+                  /* https://sourceware.org/ml/libc-hacker/2006-09/msg00008.html
+                     This test needs valgrind to catch the bug on Debian
+                     GNU/Linux 3.1 x86, but it might catch the bug better
+                     on other platforms and it shouldn't hurt to try the
+                     test here.  */
+                  static char const pat[] = "insert into";
+                  static char const data[] =
+                    "\xFF\0\x12\xA2\xAA\xC4\xB1,K\x12\xC4\xB1*\xACK";
+                  re_set_syntax (RE_SYNTAX_GREP | RE_HAT_LISTS_NOT_NEWLINE
+                                 | RE_ICASE);
+                  memset (&regex, 0, sizeof regex);
+                  s = re_compile_pattern (pat, sizeof pat - 1, &regex);
+                  if (s)
+                    result |= 1;
+                  else
+                    {
+                      if (re_search (&regex, data, sizeof data - 1,
+                                     0, sizeof data - 1, &regs)
+                          != -1)
+                        result |= 1;
+                      regfree (&regex);
+                    }
+                }
+
+                {
+                  /* This test is from glibc bug 15078.
+                     The test case is from Andreas Schwab in
+                     <https://sourceware.org/ml/libc-alpha/2013-01/msg00967.html>.
+                     */
+                  static char const pat[] = "[^x]x";
+                  static char const data[] =
+                    /* <U1000><U103B><U103D><U1014><U103A><U102F><U1015><U103A> */
+                    "\xe1\x80\x80"
+                    "\xe1\x80\xbb"
+                    "\xe1\x80\xbd"
+                    "\xe1\x80\x94"
+                    "\xe1\x80\xba"
+                    "\xe1\x80\xaf"
+                    "\xe1\x80\x95"
+                    "\xe1\x80\xba"
+                    "x";
+                  re_set_syntax (0);
+                  memset (&regex, 0, sizeof regex);
+                  s = re_compile_pattern (pat, sizeof pat - 1, &regex);
+                  if (s)
+                    result |= 1;
+                  else
+                    {
+                      i = re_search (&regex, data, sizeof data - 1,
+                                     0, sizeof data - 1, 0);
+                      if (i != 0 && i != 21)
+                        result |= 1;
+                      regfree (&regex);
+                    }
+                }
+
+                if (! setlocale (LC_ALL, "C"))
+                  return 1;
+              }
+
+            /* This test is from glibc bug 3957, reported by Andrew Mackey.  */
+            re_set_syntax (RE_SYNTAX_EGREP | RE_HAT_LISTS_NOT_NEWLINE);
+            memset (&regex, 0, sizeof regex);
+            s = re_compile_pattern ("a[^x]b", 6, &regex);
+            if (s)
+              result |= 2;
+            else
+              {
+                /* This should fail, but succeeds for glibc-2.5.  */
+                if (re_search (&regex, "a\nb", 3, 0, 3, &regs) != -1)
+                  result |= 2;
+                regfree (&regex);
+              }
+
+            /* This regular expression is from Spencer ere test number 75
+               in grep-2.3.  */
+            re_set_syntax (RE_SYNTAX_POSIX_EGREP);
+            memset (&regex, 0, sizeof regex);
+            for (i = 0; i <= UCHAR_MAX; i++)
+              folded_chars[i] = i;
+            regex.translate = folded_chars;
+            s = re_compile_pattern ("a[[:]:]]b\n", 11, &regex);
+            /* This should fail with _Invalid character class name_ error.  */
+            if (!s)
+              {
+                result |= 4;
+                regfree (&regex);
+              }
+
+            /* Ensure that [b-a] is diagnosed as invalid, when
+               using RE_NO_EMPTY_RANGES. */
+            re_set_syntax (RE_SYNTAX_POSIX_EGREP | RE_NO_EMPTY_RANGES);
+            memset (&regex, 0, sizeof regex);
+            s = re_compile_pattern ("a[b-a]", 6, &regex);
+            if (s == 0)
+              {
+                result |= 8;
+                regfree (&regex);
+              }
+
+            /* This should succeed, but does not for glibc-2.1.3.  */
+            memset (&regex, 0, sizeof regex);
+            s = re_compile_pattern ("{1", 2, &regex);
+            if (s)
+              result |= 8;
+            else
+              regfree (&regex);
+
+            /* The following example is derived from a problem report
+               against gawk from Jorge Stolfi <stolfi@ic.unicamp.br>.  */
+            memset (&regex, 0, sizeof regex);
+            s = re_compile_pattern ("[an\371]*n", 7, &regex);
+            if (s)
+              result |= 8;
+            else
+              {
+                /* This should match, but does not for glibc-2.2.1.  */
+                if (re_match (&regex, "an", 2, 0, &regs) != 2)
+                  result |= 8;
+                else
+                  {
+                    free (regs.start);
+                    free (regs.end);
+                  }
+                regfree (&regex);
+              }
+
+            memset (&regex, 0, sizeof regex);
+            s = re_compile_pattern ("x", 1, &regex);
+            if (s)
+              result |= 8;
+            else
+              {
+                /* glibc-2.2.93 does not work with a negative RANGE argument.  */
+                if (re_search (&regex, "wxy", 3, 2, -2, &regs) != 1)
+                  result |= 8;
+                else
+                  {
+                    free (regs.start);
+                    free (regs.end);
+                  }
+                regfree (&regex);
+              }
+
+            /* The version of regex.c in older versions of gnulib
+               ignored RE_ICASE.  Detect that problem too.  */
+            re_set_syntax (RE_SYNTAX_EMACS | RE_ICASE);
+            memset (&regex, 0, sizeof regex);
+            s = re_compile_pattern ("x", 1, &regex);
+            if (s)
+              result |= 16;
+            else
+              {
+                if (re_search (&regex, "WXY", 3, 0, 3, &regs) < 0)
+                  result |= 16;
+                else
+                  {
+                    free (regs.start);
+                    free (regs.end);
+                  }
+                regfree (&regex);
+              }
+
+            /* Catch a bug reported by Vin Shelton in
+               https://lists.gnu.org/r/bug-coreutils/2007-06/msg00089.html
+               */
+            re_set_syntax (RE_SYNTAX_POSIX_BASIC
+                           & ~RE_CONTEXT_INVALID_DUP
+                           & ~RE_NO_EMPTY_RANGES);
+            memset (&regex, 0, sizeof regex);
+            s = re_compile_pattern ("[[:alnum:]_-]\\\\+$", 16, &regex);
+            if (s)
+              result |= 32;
+            else
+              regfree (&regex);
+
+            /* REG_STARTEND was added to glibc on 2004-01-15.
+               Reject older versions.  */
+            if (! REG_STARTEND)
+              result |= 64;
 
+            /* Matching with the compiled form of this regexp would provoke
+               an assertion failure prior to glibc-2.28:
+                 regexec.c:1375: pop_fail_stack: Assertion 'num >= 0' failed
+               With glibc-2.28, compilation fails and reports the invalid
+               back reference.  */
+            re_set_syntax (RE_SYNTAX_POSIX_EGREP);
+            memset (&regex, 0, sizeof regex);
+            s = re_compile_pattern ("0|()0|\\1|0", 10, &regex);
+            if (!s)
+              result |= 64;
+            else
+              {
+                if (strcmp (s, "Invalid back reference"))
+                  result |= 64;
+                regfree (&regex);
+              }
 
-$gl_mda_defines
+#if 0
+            /* It would be nice to reject hosts whose regoff_t values are too
+               narrow (including glibc on hosts with 64-bit ptrdiff_t and
+               32-bit int), but we should wait until glibc implements this
+               feature.  Otherwise, support for equivalence classes and
+               multibyte collation symbols would always be broken except
+               when compiling --without-included-regex.   */
+            if (sizeof (regoff_t) < sizeof (ptrdiff_t)
+                || sizeof (regoff_t) < sizeof (ssize_t))
+              result |= 64;
+#endif
 
-int
-main (void)
-{
-int result = 0;
-           if (!rmdir ("conftest.file/"))
-             result |= 1;
-           else if (errno != ENOTDIR)
-             result |= 2;
-           if (!rmdir ("conftest.dir/./"))
-             result |= 4;
-           return result;
+            return result;
 
   ;
   return 0;
@@ -44242,102 +44291,115 @@
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_func_rmdir_works=yes
+  gl_cv_func_re_compile_pattern_working=yes
 else $as_nop
-  gl_cv_func_rmdir_works=no
+  gl_cv_func_re_compile_pattern_working=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
-     rm -rf conftest.dir conftest.file
+
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_rmdir_works" >&5
-printf "%s\n" "$gl_cv_func_rmdir_works" >&6; }
-  case "$gl_cv_func_rmdir_works" in
-    *yes) ;;
-    *)
-      REPLACE_RMDIR=1
-      ;;
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_re_compile_pattern_working" >&5
+printf "%s\n" "$gl_cv_func_re_compile_pattern_working" >&6; }
+    case "$gl_cv_func_re_compile_pattern_working" in #(
+      *yes) ac_use_included_regex=no;; #(
+      *no) ac_use_included_regex=yes;;
+    esac
+    ;;
+  *) as_fn_error $? "Invalid value for --with-included-regex: $with_included_regex" "$LINENO" 5
+    ;;
   esac
 
-  if test $REPLACE_RMDIR = 1; then
-
+  if test $ac_use_included_regex = yes; then
 
+printf "%s\n" "#define _REGEX_INCLUDE_LIMITS_H 1" >>confdefs.h
 
 
+printf "%s\n" "#define _REGEX_LARGE_OFFSETS 1" >>confdefs.h
 
 
+printf "%s\n" "#define re_syntax_options rpl_re_syntax_options" >>confdefs.h
 
 
-  M4_LIBOBJS="$M4_LIBOBJS rmdir.$ac_objext"
+printf "%s\n" "#define re_set_syntax rpl_re_set_syntax" >>confdefs.h
 
-  fi
 
+printf "%s\n" "#define re_compile_pattern rpl_re_compile_pattern" >>confdefs.h
 
 
+printf "%s\n" "#define re_compile_fastmap rpl_re_compile_fastmap" >>confdefs.h
 
 
+printf "%s\n" "#define re_search rpl_re_search" >>confdefs.h
 
 
+printf "%s\n" "#define re_search_2 rpl_re_search_2" >>confdefs.h
 
 
-          GL_M4_GNULIB_RMDIR=1
+printf "%s\n" "#define re_match rpl_re_match" >>confdefs.h
 
 
+printf "%s\n" "#define re_match_2 rpl_re_match_2" >>confdefs.h
 
 
+printf "%s\n" "#define re_set_registers rpl_re_set_registers" >>confdefs.h
 
-printf "%s\n" "#define GNULIB_TEST_RMDIR 1" >>confdefs.h
 
+printf "%s\n" "#define re_comp rpl_re_comp" >>confdefs.h
 
 
+printf "%s\n" "#define re_exec rpl_re_exec" >>confdefs.h
 
 
+printf "%s\n" "#define regcomp rpl_regcomp" >>confdefs.h
 
 
+printf "%s\n" "#define regexec rpl_regexec" >>confdefs.h
 
 
+printf "%s\n" "#define regerror rpl_regerror" >>confdefs.h
 
 
+printf "%s\n" "#define regfree rpl_regfree" >>confdefs.h
 
+  fi
 
+  if test $ac_use_included_regex = yes; then
 
 
 
 
-  if test $ac_cv_func_secure_getenv = no; then
-    HAVE_SECURE_GETENV=0
-  fi
 
-  if test $HAVE_SECURE_GETENV = 0; then
 
 
 
+  M4_LIBOBJS="$M4_LIBOBJS regex.$ac_objext"
 
 
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS secure_getenv.$ac_objext"
 
 
-  ac_fn_c_check_func "$LINENO" "__secure_getenv" "ac_cv_func___secure_getenv"
-if test "x$ac_cv_func___secure_getenv" = xyes
+  ac_fn_c_check_header_compile "$LINENO" "libintl.h" "ac_cv_header_libintl_h" "$ac_includes_default"
+if test "x$ac_cv_header_libintl_h" = xyes
 then :
-  printf "%s\n" "#define HAVE___SECURE_GETENV 1" >>confdefs.h
+  printf "%s\n" "#define HAVE_LIBINTL_H 1" >>confdefs.h
 
 fi
 
-  if test $ac_cv_func___secure_getenv = no; then
-    ac_fn_c_check_func "$LINENO" "issetugid" "ac_cv_func_issetugid"
-if test "x$ac_cv_func_issetugid" = xyes
-then :
-  printf "%s\n" "#define HAVE_ISSETUGID 1" >>confdefs.h
 
+  ac_fn_check_decl "$LINENO" "isblank" "ac_cv_have_decl_isblank" "#include <ctype.h>
+" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_isblank" = xyes
+then :
+  ac_have_decl=1
+else $as_nop
+  ac_have_decl=0
 fi
-
-  fi
+printf "%s\n" "#define HAVE_DECL_ISBLANK $ac_have_decl" >>confdefs.h
 
 
   fi
@@ -44346,1294 +44408,989 @@
 
 
 
-
-
-
-
-          GL_M4_GNULIB_SECURE_GETENV=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_SECURE_GETENV 1" >>confdefs.h
-
-
-
-
-
-
-
-
-    NEED_SETLOCALE_IMPROVED=0
-  case "$host_os" in
-            mingw*) NEED_SETLOCALE_IMPROVED=1 ;;
-            cygwin*)
-      case `uname -r` in
-        1.5.*) NEED_SETLOCALE_IMPROVED=1 ;;
-      esac
-      ;;
-        *)
-      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether setlocale supports the C locale" >&5
-printf %s "checking whether setlocale supports the C locale... " >&6; }
-if test ${gl_cv_func_setlocale_works+y}
+                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether rename honors trailing slash on destination" >&5
+printf %s "checking whether rename honors trailing slash on destination... " >&6; }
+if test ${gl_cv_func_rename_slash_dst_works+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  if test "$cross_compiling" = yes
+  rm -rf conftest.f conftest.f1 conftest.f2 conftest.d1 conftest.d2 conftest.lnk
+    touch conftest.f && touch conftest.f1 && mkdir conftest.d1 ||
+      as_fn_error $? "cannot create temporary files" "$LINENO" 5
+    # Assume that if we have lstat, we can also check symlinks.
+    if test $ac_cv_func_lstat = yes; then
+      ln -s conftest.f conftest.lnk
+    fi
+    if test "$cross_compiling" = yes
 then :
-  case "$host_os" in
-                               # Guess no on Android.
-              linux*-android*) gl_cv_func_setlocale_works="guessing no";;
-                               # Guess yes otherwise.
-              *)               gl_cv_func_setlocale_works="guessing yes";;
-            esac
+        case "$host_os" in
+                          # Guess yes on Linux systems.
+         linux-* | linux) gl_cv_func_rename_slash_dst_works="guessing yes" ;;
+                          # Guess yes on glibc systems.
+         *-gnu*)          gl_cv_func_rename_slash_dst_works="guessing yes" ;;
+                          # Guess no on native Windows.
+         mingw*)          gl_cv_func_rename_slash_dst_works="guessing no" ;;
+                          # If we don't know, obey --enable-cross-guesses.
+         *)               gl_cv_func_rename_slash_dst_works="$gl_cross_guess_normal" ;;
+       esac
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
-#include <locale.h>
-int main ()
+#        include <stdio.h>
+#        include <stdlib.h>
+
+int
+main (void)
 {
-  return setlocale (LC_ALL, "C") == NULL;
+int result = 0;
+           if (rename ("conftest.f1", "conftest.f2/") == 0)
+             result |= 1;
+           if (rename ("conftest.d1", "conftest.d2/") != 0)
+             result |= 2;
+#if HAVE_LSTAT
+           if (rename ("conftest.f", "conftest.lnk/") == 0)
+             result |= 4;
+#endif
+           return result;
+
+  ;
+  return 0;
 }
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_func_setlocale_works=yes
+  gl_cv_func_rename_slash_dst_works=yes
 else $as_nop
-  gl_cv_func_setlocale_works=no
+  gl_cv_func_rename_slash_dst_works=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
+    rm -rf conftest.f conftest.f1 conftest.f2 conftest.d1 conftest.d2 conftest.lnk
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_setlocale_works" >&5
-printf "%s\n" "$gl_cv_func_setlocale_works" >&6; }
-      case "$gl_cv_func_setlocale_works" in
-        *yes) ;;
-        *) NEED_SETLOCALE_IMPROVED=1 ;;
-      esac
-      ;;
-  esac
-
-printf "%s\n" "#define NEED_SETLOCALE_IMPROVED $NEED_SETLOCALE_IMPROVED" >>confdefs.h
-
-
-    NEED_SETLOCALE_MTSAFE=0
-  if test $SETLOCALE_NULL_ALL_MTSAFE = 0 || test $SETLOCALE_NULL_ONE_MTSAFE = 0; then
-    NEED_SETLOCALE_MTSAFE=1
-  fi
-
-printf "%s\n" "#define NEED_SETLOCALE_MTSAFE $NEED_SETLOCALE_MTSAFE" >>confdefs.h
-
-
-  if test $NEED_SETLOCALE_IMPROVED = 1 || test $NEED_SETLOCALE_MTSAFE = 1; then
-    REPLACE_SETLOCALE=1
-  fi
-
-  if test $NEED_SETLOCALE_MTSAFE = 1; then
-    LIB_SETLOCALE="$LIB_SETLOCALE_NULL"
-  else
-    LIB_SETLOCALE=
-  fi
-
-
-  if test $REPLACE_SETLOCALE = 1; then
-
-
-
-
-
-
-
-
-  M4_LIBOBJS="$M4_LIBOBJS setlocale.$ac_objext"
-
-
-        :
-
-  fi
-
-
-
-
-
-
-
-
-
-          GL_M4_GNULIB_SETLOCALE=1
-
-
-
-
-
-printf "%s\n" "#define GNULIB_TEST_SETLOCALE 1" >>confdefs.h
-
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_rename_slash_dst_works" >&5
+printf "%s\n" "$gl_cv_func_rename_slash_dst_works" >&6; }
+  case "$gl_cv_func_rename_slash_dst_works" in
+    *yes) ;;
+    *)
+      REPLACE_RENAME=1
 
+printf "%s\n" "#define RENAME_TRAILING_SLASH_DEST_BUG 1" >>confdefs.h
 
+      ;;
+  esac
 
+            { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether rename honors trailing slash on source" >&5
+printf %s "checking whether rename honors trailing slash on source... " >&6; }
+if test ${gl_cv_func_rename_slash_src_works+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  rm -rf conftest.f conftest.f1 conftest.d1 conftest.d2 conftest.d3 conftest.lnk
+    touch conftest.f && touch conftest.f1 && mkdir conftest.d1 ||
+      as_fn_error $? "cannot create temporary files" "$LINENO" 5
+    # Assume that if we have lstat, we can also check symlinks.
+    if test $ac_cv_func_lstat = yes; then
+      ln -s conftest.f conftest.lnk
+    fi
+    if test "$cross_compiling" = yes
+then :
+        case "$host_os" in
+                          # Guess yes on Linux systems.
+         linux-* | linux) gl_cv_func_rename_slash_src_works="guessing yes" ;;
+                          # Guess yes on glibc systems.
+         *-gnu*)          gl_cv_func_rename_slash_src_works="guessing yes" ;;
+                          # Guess yes on native Windows.
+         mingw*)          gl_cv_func_rename_slash_src_works="guessing yes" ;;
+                          # If we don't know, obey --enable-cross-guesses.
+         *)               gl_cv_func_rename_slash_src_works="$gl_cross_guess_normal" ;;
+       esac
 
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
+#        include <stdio.h>
+#        include <stdlib.h>
 
+int
+main (void)
+{
+int result = 0;
+           if (rename ("conftest.f1/", "conftest.d3") == 0)
+             result |= 1;
+           if (rename ("conftest.d1/", "conftest.d2") != 0)
+             result |= 2;
+#if HAVE_LSTAT
+           if (rename ("conftest.lnk/", "conftest.f") == 0)
+             result |= 4;
+#endif
+           return result;
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether setlocale (LC_ALL, NULL) is multithread-safe" >&5
-printf %s "checking whether setlocale (LC_ALL, NULL) is multithread-safe... " >&6; }
-if test ${gl_cv_func_setlocale_null_all_mtsafe+y}
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
 then :
-  printf %s "(cached) " >&6
+  gl_cv_func_rename_slash_src_works=yes
 else $as_nop
-  case "$host_os" in
-       # Guess no on musl libc, macOS, FreeBSD, NetBSD, OpenBSD, AIX, Haiku, Cygwin.
-       *-musl* | darwin* | freebsd* | midnightbsd* | netbsd* | openbsd* | aix* | haiku* | cygwin*)
-         gl_cv_func_setlocale_null_all_mtsafe=no ;;
-       # Guess yes on glibc, HP-UX, IRIX, Solaris, native Windows.
-       *-gnu* | gnu* | hpux* | irix* | solaris* | mingw*)
-         gl_cv_func_setlocale_null_all_mtsafe=yes ;;
-       # If we don't know, obey --enable-cross-guesses.
-       *)
-         gl_cv_func_setlocale_null_all_mtsafe="$gl_cross_guess_normal" ;;
-     esac
+  gl_cv_func_rename_slash_src_works=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
+
+    rm -rf conftest.f conftest.f1 conftest.d1 conftest.d2 conftest.d3 conftest.lnk
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_setlocale_null_all_mtsafe" >&5
-printf "%s\n" "$gl_cv_func_setlocale_null_all_mtsafe" >&6; }
-    case "$host_os" in
-    mingw*) ;;
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_rename_slash_src_works" >&5
+printf "%s\n" "$gl_cv_func_rename_slash_src_works" >&6; }
+  case "$gl_cv_func_rename_slash_src_works" in
+    *yes) ;;
     *)
-      if test $gl_pthread_api = no && test $ac_cv_header_threads_h = no; then
-        gl_cv_func_setlocale_null_all_mtsafe="trivially yes"
-      fi
+      REPLACE_RENAME=1
+
+printf "%s\n" "#define RENAME_TRAILING_SLASH_SOURCE_BUG 1" >>confdefs.h
+
       ;;
   esac
-  case "$gl_cv_func_setlocale_null_all_mtsafe" in
-    *yes) SETLOCALE_NULL_ALL_MTSAFE=1 ;;
-    *)    SETLOCALE_NULL_ALL_MTSAFE=0 ;;
-  esac
-
-printf "%s\n" "#define SETLOCALE_NULL_ALL_MTSAFE $SETLOCALE_NULL_ALL_MTSAFE" >>confdefs.h
 
 
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether setlocale (category, NULL) is multithread-safe" >&5
-printf %s "checking whether setlocale (category, NULL) is multithread-safe... " >&6; }
-if test ${gl_cv_func_setlocale_null_one_mtsafe+y}
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether rename manages hard links correctly" >&5
+printf %s "checking whether rename manages hard links correctly... " >&6; }
+if test ${gl_cv_func_rename_link_works+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  case "$host_os" in
-       # Guess no on OpenBSD, AIX.
-       openbsd* | aix*)
-         gl_cv_func_setlocale_null_one_mtsafe=no ;;
-       # Guess yes on glibc, musl libc, macOS, FreeBSD, NetBSD, HP-UX, IRIX, Solaris, Haiku, Cygwin, native Windows.
-       *-gnu* | gnu* | *-musl* | darwin* | freebsd* | midnightbsd* | netbsd* | hpux* | irix* | solaris* | haiku* | cygwin* | mingw*)
-         gl_cv_func_setlocale_null_one_mtsafe=yes ;;
-       # If we don't know, obey --enable-cross-guesses.
-       *)
-         gl_cv_func_setlocale_null_one_mtsafe="$gl_cross_guess_normal" ;;
-     esac
-
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_setlocale_null_one_mtsafe" >&5
-printf "%s\n" "$gl_cv_func_setlocale_null_one_mtsafe" >&6; }
-    case "$host_os" in
-    mingw*) ;;
-    *)
-      if test $gl_pthread_api = no && test $ac_cv_header_threads_h = no; then
-        gl_cv_func_setlocale_null_one_mtsafe="trivially yes"
-      fi
-      ;;
-  esac
-  case "$gl_cv_func_setlocale_null_one_mtsafe" in
-    *yes) SETLOCALE_NULL_ONE_MTSAFE=1 ;;
-    *)    SETLOCALE_NULL_ONE_MTSAFE=0 ;;
-  esac
+  if test $ac_cv_func_link = yes; then
+       if test $cross_compiling != yes; then
+         rm -rf conftest.f conftest.f1 conftest.f2
+         if touch conftest.f conftest.f2 && ln conftest.f conftest.f1 &&
+             set x `ls -i conftest.f conftest.f1` && test "" = ""; then
+           if test "$cross_compiling" = yes
+then :
+                :
 
-printf "%s\n" "#define SETLOCALE_NULL_ONE_MTSAFE $SETLOCALE_NULL_ONE_MTSAFE" >>confdefs.h
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
+#               include <errno.h>
+#               include <stdio.h>
+#               include <stdlib.h>
+#               include <unistd.h>
 
-    if test $SETLOCALE_NULL_ALL_MTSAFE = 0 || test $SETLOCALE_NULL_ONE_MTSAFE = 0; then
-    case "$host_os" in
-      mingw*) LIB_SETLOCALE_NULL= ;;
-      *)
 
+$gl_mda_defines
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether imported symbols can be declared weak" >&5
-printf %s "checking whether imported symbols can be declared weak... " >&6; }
-if test ${gl_cv_have_weak+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  gl_cv_have_weak=no
-          cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-extern void xyzzy ();
-#pragma weak xyzzy
 int
 main (void)
 {
-xyzzy();
+int result = 0;
+                  if (rename ("conftest.f", "conftest.f1"))
+                    result |= 1;
+                  if (unlink ("conftest.f1"))
+                    result |= 2;
+
+                  /* Allow either the POSIX-required behavior, where the
+                     previous rename kept conftest.f, or the (better) NetBSD
+                     behavior, where it removed conftest.f.  */
+                  if (rename ("conftest.f", "conftest.f") != 0
+                      && errno != ENOENT)
+                    result |= 4;
+
+                  if (rename ("conftest.f1", "conftest.f1") == 0)
+                    result |= 8;
+                  if (rename ("conftest.f2", "conftest.f2") != 0)
+                    result |= 16;
+                  return result;
+
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"
+if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_have_weak=maybe
+  gl_cv_func_rename_link_works=yes
+else $as_nop
+  gl_cv_func_rename_link_works=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
-     if test $gl_cv_have_weak = maybe; then
-                     if test "$cross_compiling" = yes
-then :
-                      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#ifdef __ELF__
-             Extensible Linking Format
-             #endif
 
-_ACEOF
-if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
-  $EGREP "Extensible Linking Format" >/dev/null 2>&1
+         else
+           gl_cv_func_rename_link_works="guessing no"
+         fi
+         rm -rf conftest.f conftest.f1 conftest.f2
+       else
+                  case "$host_os" in
+                            # Guess yes on Linux systems.
+           linux-* | linux) gl_cv_func_rename_link_works="guessing yes" ;;
+                            # Guess yes on glibc systems.
+           *-gnu*)          gl_cv_func_rename_link_works="guessing yes" ;;
+                            # Guess yes on native Windows.
+           mingw*)          gl_cv_func_rename_link_works="guessing yes" ;;
+                            # If we don't know, obey --enable-cross-guesses.
+           *)               gl_cv_func_rename_link_works="$gl_cross_guess_normal" ;;
+         esac
+       fi
+     else
+       gl_cv_func_rename_link_works=yes
+     fi
+
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_rename_link_works" >&5
+printf "%s\n" "$gl_cv_func_rename_link_works" >&6; }
+  case "$gl_cv_func_rename_link_works" in
+    *yes) ;;
+    *)
+      REPLACE_RENAME=1
+
+printf "%s\n" "#define RENAME_HARD_LINK_BUG 1" >>confdefs.h
+
+      ;;
+  esac
+
+          { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether rename manages existing destinations correctly" >&5
+printf %s "checking whether rename manages existing destinations correctly... " >&6; }
+if test ${gl_cv_func_rename_dest_works+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  rm -rf conftest.f conftest.d1 conftest.d2
+    touch conftest.f && mkdir conftest.d1 conftest.d2 ||
+      as_fn_error $? "cannot create temporary files" "$LINENO" 5
+    if test "$cross_compiling" = yes
 then :
-  gl_cv_have_weak="guessing yes"
-else $as_nop
-  gl_cv_have_weak="guessing no"
-fi
-rm -rf conftest*
-
+        case "$host_os" in
+                          # Guess yes on Linux systems.
+         linux-* | linux) gl_cv_func_rename_dest_works="guessing yes" ;;
+                          # Guess yes on glibc systems.
+         *-gnu*)          gl_cv_func_rename_dest_works="guessing yes" ;;
+                          # Guess no on native Windows.
+         mingw*)          gl_cv_func_rename_dest_works="guessing no" ;;
+                          # If we don't know, obey --enable-cross-guesses.
+         *)               gl_cv_func_rename_dest_works="$gl_cross_guess_normal" ;;
+       esac
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
-#include <stdio.h>
-#pragma weak fputs
-int main ()
+#        include <stdio.h>
+#        include <stdlib.h>
+
+int
+main (void)
 {
-  return (fputs == NULL);
+int result = 0;
+           if (rename ("conftest.d1", "conftest.d2") != 0)
+             result |= 1;
+           if (rename ("conftest.d2", "conftest.f") == 0)
+             result |= 2;
+           return result;
+
+  ;
+  return 0;
 }
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_have_weak=yes
+  gl_cv_func_rename_dest_works=yes
 else $as_nop
-  gl_cv_have_weak=no
+  gl_cv_func_rename_dest_works=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
-     fi
-          case " $LDFLAGS " in
-       *" -static "*) gl_cv_have_weak=no ;;
-     esac
-                    case "$gl_cv_have_weak" in
-       *yes)
-         case "$host_os" in
-           freebsd* | dragonfly* | midnightbsd*)
-             : > conftest1.c
-             $CC $CPPFLAGS $CFLAGS $LDFLAGS -fPIC -shared -o libempty.so conftest1.c -lpthread >&5 2>&1
-             cat <<EOF > conftest2.c
-#include <pthread.h>
-#pragma weak pthread_mutexattr_gettype
-int main ()
-{
-  return (pthread_mutexattr_gettype != NULL);
-}
-EOF
-             $CC $CPPFLAGS $CFLAGS $LDFLAGS -o conftest conftest2.c libempty.so >&5 2>&1 \
-               || gl_cv_have_weak=no
-             rm -f conftest1.c libempty.so conftest2.c conftest
-             ;;
-         esac
-         ;;
-     esac
+    rm -rf conftest.f conftest.d1 conftest.d2
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_have_weak" >&5
-printf "%s\n" "$gl_cv_have_weak" >&6; }
-  case "$gl_cv_have_weak" in
-    *yes)
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_rename_dest_works" >&5
+printf "%s\n" "$gl_cv_func_rename_dest_works" >&6; }
+  case "$gl_cv_func_rename_dest_works" in
+    *yes) ;;
+    *)
+      REPLACE_RENAME=1
 
-printf "%s\n" "#define HAVE_WEAK_SYMBOLS 1" >>confdefs.h
+printf "%s\n" "#define RENAME_DEST_EXISTS_BUG 1" >>confdefs.h
 
       ;;
   esac
 
-        case "$gl_cv_have_weak" in
-          *yes) LIB_SETLOCALE_NULL= ;;
-          *)    LIB_SETLOCALE_NULL="$LIBPTHREAD" ;;
-        esac
-        ;;
-    esac
-  else
-    LIB_SETLOCALE_NULL=
-  fi
-
-
-  if test $SETLOCALE_NULL_ALL_MTSAFE = 0 || test $SETLOCALE_NULL_ONE_MTSAFE = 0; then
-
-
+  if test $REPLACE_RENAME = 1; then
 
 
 
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS setlocale-lock.$ac_objext"
 
 
+  M4_LIBOBJS="$M4_LIBOBJS rename.$ac_objext"
 
+  fi
 
-  CFLAG_VISIBILITY=
-  HAVE_VISIBILITY=0
-  if test -n "$GCC"; then
-                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether the -Werror option is usable" >&5
-printf %s "checking whether the -Werror option is usable... " >&6; }
-if test ${gl_cv_cc_vis_werror+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  gl_save_CFLAGS="$CFLAGS"
-       CFLAGS="$CFLAGS -Werror"
-       cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
 
-int
-main (void)
-{
 
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  gl_cv_cc_vis_werror=yes
-else $as_nop
-  gl_cv_cc_vis_werror=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-       CFLAGS="$gl_save_CFLAGS"
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_cc_vis_werror" >&5
-printf "%s\n" "$gl_cv_cc_vis_werror" >&6; }
-        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for simple visibility declarations" >&5
-printf %s "checking for simple visibility declarations... " >&6; }
-if test ${gl_cv_cc_visibility+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
-  gl_save_CFLAGS="$CFLAGS"
-       CFLAGS="$CFLAGS -fvisibility=hidden"
-                                          if test $gl_cv_cc_vis_werror = yes; then
-         CFLAGS="$CFLAGS -Werror"
-       fi
-       cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-extern __attribute__((__visibility__("hidden"))) int hiddenvar;
-              extern __attribute__((__visibility__("default"))) int exportedvar;
-              extern __attribute__((__visibility__("hidden"))) int hiddenfunc (void);
-              extern __attribute__((__visibility__("default"))) int exportedfunc (void);
-              void dummyfunc (void);
-              void dummyfunc (void) {}
 
-int
-main (void)
-{
 
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"
-then :
-  gl_cv_cc_visibility=yes
-else $as_nop
-  gl_cv_cc_visibility=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
-       CFLAGS="$gl_save_CFLAGS"
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_cc_visibility" >&5
-printf "%s\n" "$gl_cv_cc_visibility" >&6; }
-    if test $gl_cv_cc_visibility = yes; then
-      CFLAG_VISIBILITY="-fvisibility=hidden"
-      HAVE_VISIBILITY=1
-    fi
-  fi
 
 
+          GL_M4_GNULIB_RENAME=1
 
-printf "%s\n" "#define HAVE_VISIBILITY $HAVE_VISIBILITY" >>confdefs.h
 
 
 
-  fi
 
+printf "%s\n" "#define GNULIB_TEST_RENAME 1" >>confdefs.h
 
 
 
 
 
 
+  ac_fn_c_check_func "$LINENO" "rewinddir" "ac_cv_func_rewinddir"
+if test "x$ac_cv_func_rewinddir" = xyes
+then :
+  printf "%s\n" "#define HAVE_REWINDDIR 1" >>confdefs.h
 
+fi
 
-          GL_M4_GNULIB_SETLOCALE_NULL=1
+  if test $ac_cv_func_rewinddir = no; then
+    HAVE_REWINDDIR=0
+  fi
 
+  if test $HAVE_REWINDDIR = 0; then
 
 
 
 
-printf "%s\n" "#define GNULIB_TEST_SETLOCALE_NULL 1" >>confdefs.h
 
 
 
 
+  M4_LIBOBJS="$M4_LIBOBJS rewinddir.$ac_objext"
 
+  fi
 
 
 
 
-  if test $ac_cv_func_sigaction = yes; then
-    ac_fn_c_check_member "$LINENO" "struct sigaction" "sa_sigaction" "ac_cv_member_struct_sigaction_sa_sigaction" "#include <signal.h>
-"
-if test "x$ac_cv_member_struct_sigaction_sa_sigaction" = xyes
-then :
 
-printf "%s\n" "#define HAVE_STRUCT_SIGACTION_SA_SIGACTION 1" >>confdefs.h
 
 
-fi
 
-    if test $ac_cv_member_struct_sigaction_sa_sigaction = no; then
-      HAVE_STRUCT_SIGACTION_SA_SIGACTION=0
-    fi
-  else
-    HAVE_SIGACTION=0
-  fi
 
-  if test $HAVE_SIGACTION = 0; then
+          GL_M4_GNULIB_REWINDDIR=1
 
 
 
 
 
+printf "%s\n" "#define GNULIB_TEST_REWINDDIR 1" >>confdefs.h
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS sigaction.$ac_objext"
 
 
 
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether rmdir works" >&5
+printf %s "checking whether rmdir works... " >&6; }
+if test ${gl_cv_func_rmdir_works+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  mkdir conftest.dir
+     touch conftest.file
+     if test "$cross_compiling" = yes
+then :
+  case "$host_os" in
+                           # Guess yes on Linux systems.
+          linux-* | linux) gl_cv_func_rmdir_works="guessing yes" ;;
+                           # Guess yes on glibc systems.
+          *-gnu* | gnu*)   gl_cv_func_rmdir_works="guessing yes" ;;
+                           # Guess no on native Windows.
+          mingw*)          gl_cv_func_rmdir_works="guessing no" ;;
+                           # If we don't know, obey --enable-cross-guesses.
+          *)               gl_cv_func_rmdir_works="$gl_cross_guess_normal" ;;
+        esac
 
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <stdio.h>
+           #include <errno.h>
+           #if HAVE_UNISTD_H
+           # include <unistd.h>
+           #else /* on Windows with MSVC */
+           # include <direct.h>
+           #endif
 
 
+$gl_mda_defines
 
-  ac_fn_c_check_type "$LINENO" "siginfo_t" "ac_cv_type_siginfo_t" "
-#include <signal.h>
+int
+main (void)
+{
+int result = 0;
+           if (!rmdir ("conftest.file/"))
+             result |= 1;
+           else if (errno != ENOTDIR)
+             result |= 2;
+           if (!rmdir ("conftest.dir/./"))
+             result |= 4;
+           return result;
 
-"
-if test "x$ac_cv_type_siginfo_t" = xyes
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
 then :
+  gl_cv_func_rmdir_works=yes
+else $as_nop
+  gl_cv_func_rmdir_works=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
 
-printf "%s\n" "#define HAVE_SIGINFO_T 1" >>confdefs.h
+     rm -rf conftest.dir conftest.file
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_rmdir_works" >&5
+printf "%s\n" "$gl_cv_func_rmdir_works" >&6; }
+  case "$gl_cv_func_rmdir_works" in
+    *yes) ;;
+    *)
+      REPLACE_RMDIR=1
+      ;;
+  esac
 
+  if test $REPLACE_RMDIR = 1; then
 
-fi
 
-  if test $ac_cv_type_siginfo_t = no; then
-    HAVE_SIGINFO_T=0
-  fi
 
-  fi
 
 
 
 
 
+  M4_LIBOBJS="$M4_LIBOBJS rmdir.$ac_objext"
 
+  fi
 
 
 
-          GL_M4_GNULIB_SIGACTION=1
 
 
 
 
 
-printf "%s\n" "#define GNULIB_TEST_SIGACTION 1" >>confdefs.h
 
+          GL_M4_GNULIB_RMDIR=1
 
 
 
 
 
+printf "%s\n" "#define GNULIB_TEST_RMDIR 1" >>confdefs.h
 
 
 
 
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for signbit macro" >&5
-printf %s "checking for signbit macro... " >&6; }
-if test ${gl_cv_func_signbit+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-      if test "$cross_compiling" = yes
-then :
-  case "$host_os" in
-                          # Guess yes on glibc systems.
-           *-gnu* | gnu*) gl_cv_func_signbit="guessing yes" ;;
-                          # Guess yes on musl systems.
-           *-musl*)       gl_cv_func_signbit="guessing yes" ;;
-                          # Guess yes on native Windows.
-           mingw*)        gl_cv_func_signbit="guessing yes" ;;
-                          # If we don't know, obey --enable-cross-guesses.
-           *)             gl_cv_func_signbit="$gl_cross_guess_normal" ;;
-         esac
 
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
 
-#include <math.h>
-/* If signbit is defined as a function, don't use it, since calling it for
-   'float' or 'long double' arguments would involve conversions.
-   If signbit is not declared at all but exists as a library function, don't
-   use it, since the prototype may not match.
-   If signbit is not declared at all but exists as a compiler built-in, don't
-   use it, since it's preferable to use __builtin_signbit* (no warnings,
-   no conversions).  */
-#ifndef signbit
-# error "signbit should be a macro"
-#endif
-#include <string.h>
 
-/* Global variables.
-   Needed because GCC 4 constant-folds __builtin_signbitl (literal)
-   but cannot constant-fold            __builtin_signbitl (variable).  */
-float vf;
-double vd;
-long double vl;
-int main ()
-{
-/* HP cc on HP-UX 10.20 has a bug with the constant expression -0.0.
-   So we use -p0f and -p0d instead.  */
-float p0f = 0.0f;
-float m0f = -p0f;
-double p0d = 0.0;
-double m0d = -p0d;
-/* On HP-UX 10.20, negating 0.0L does not yield -0.0L.
-   So we use another constant expression instead.
-   But that expression does not work on other platforms, such as when
-   cross-compiling to PowerPC on Mac OS X 10.5.  */
-long double p0l = 0.0L;
-#if defined __hpux || defined __sgi
-long double m0l = -LDBL_MIN * LDBL_MIN;
-#else
-long double m0l = -p0l;
-#endif
-  int result = 0;
-  if (signbit (vf)) /* link check */
-    vf++;
-  {
-    float plus_inf = 1.0f / p0f;
-    float minus_inf = -1.0f / p0f;
-    if (!(!signbit (255.0f)
-          && signbit (-255.0f)
-          && !signbit (p0f)
-          && (memcmp (&m0f, &p0f, sizeof (float)) == 0 || signbit (m0f))
-          && !signbit (plus_inf)
-          && signbit (minus_inf)))
-      result |= 1;
-  }
-  if (signbit (vd)) /* link check */
-    vd++;
-  {
-    double plus_inf = 1.0 / p0d;
-    double minus_inf = -1.0 / p0d;
-    if (!(!signbit (255.0)
-          && signbit (-255.0)
-          && !signbit (p0d)
-          && (memcmp (&m0d, &p0d, sizeof (double)) == 0 || signbit (m0d))
-          && !signbit (plus_inf)
-          && signbit (minus_inf)))
-      result |= 2;
-  }
-  if (signbit (vl)) /* link check */
-    vl++;
-  {
-    long double plus_inf = 1.0L / p0l;
-    long double minus_inf = -1.0L / p0l;
-    if (signbit (255.0L))
-      result |= 4;
-    if (!signbit (-255.0L))
-      result |= 4;
-    if (signbit (p0l))
-      result |= 8;
-    if (!(memcmp (&m0l, &p0l, sizeof (long double)) == 0 || signbit (m0l)))
-      result |= 16;
-    if (signbit (plus_inf))
-      result |= 32;
-    if (!signbit (minus_inf))
-      result |= 64;
-  }
-  return result;
-}
 
 
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
-then :
-  gl_cv_func_signbit=yes
-else $as_nop
-  gl_cv_func_signbit=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
 
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_signbit" >&5
-printf "%s\n" "$gl_cv_func_signbit" >&6; }
-          { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for signbit compiler built-ins" >&5
-printf %s "checking for signbit compiler built-ins... " >&6; }
-if test ${gl_cv_func_signbit_builtins+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-      if test "$cross_compiling" = yes
-then :
-  case "$host_os" in
-                          # Guess yes on glibc systems.
-           *-gnu* | gnu*) gl_cv_func_signbit_builtins="guessing yes" ;;
-                          # Guess yes on musl systems.
-           *-musl*)       gl_cv_func_signbit_builtins="guessing yes" ;;
-                          # Guess yes on mingw, no on MSVC.
-           mingw*)        if test -n "$GCC"; then
-                            gl_cv_func_signbit_builtins="guessing yes"
-                          else
-                            gl_cv_func_signbit_builtins="guessing no"
-                          fi
-                          ;;
-                          # If we don't know, obey --enable-cross-guesses.
-           *)             gl_cv_func_signbit_builtins="$gl_cross_guess_normal" ;;
-         esac
 
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
 
-#if (__GNUC__ >= 4) || (__clang_major__ >= 4)
-# define signbit(x) \
-   (sizeof (x) == sizeof (long double) ? __builtin_signbitl (x) : \
-    sizeof (x) == sizeof (double) ? __builtin_signbit (x) : \
-    __builtin_signbitf (x))
-#else
-# error "signbit should be three compiler built-ins"
-#endif
-#include <string.h>
+  if test $ac_cv_func_secure_getenv = no; then
+    HAVE_SECURE_GETENV=0
+  fi
+
+  if test $HAVE_SECURE_GETENV = 0; then
 
-/* Global variables.
-   Needed because GCC 4 constant-folds __builtin_signbitl (literal)
-   but cannot constant-fold            __builtin_signbitl (variable).  */
-float vf;
-double vd;
-long double vl;
-int main ()
-{
-/* HP cc on HP-UX 10.20 has a bug with the constant expression -0.0.
-   So we use -p0f and -p0d instead.  */
-float p0f = 0.0f;
-float m0f = -p0f;
-double p0d = 0.0;
-double m0d = -p0d;
-/* On HP-UX 10.20, negating 0.0L does not yield -0.0L.
-   So we use another constant expression instead.
-   But that expression does not work on other platforms, such as when
-   cross-compiling to PowerPC on Mac OS X 10.5.  */
-long double p0l = 0.0L;
-#if defined __hpux || defined __sgi
-long double m0l = -LDBL_MIN * LDBL_MIN;
-#else
-long double m0l = -p0l;
-#endif
-  int result = 0;
-  if (signbit (vf)) /* link check */
-    vf++;
-  {
-    float plus_inf = 1.0f / p0f;
-    float minus_inf = -1.0f / p0f;
-    if (!(!signbit (255.0f)
-          && signbit (-255.0f)
-          && !signbit (p0f)
-          && (memcmp (&m0f, &p0f, sizeof (float)) == 0 || signbit (m0f))
-          && !signbit (plus_inf)
-          && signbit (minus_inf)))
-      result |= 1;
-  }
-  if (signbit (vd)) /* link check */
-    vd++;
-  {
-    double plus_inf = 1.0 / p0d;
-    double minus_inf = -1.0 / p0d;
-    if (!(!signbit (255.0)
-          && signbit (-255.0)
-          && !signbit (p0d)
-          && (memcmp (&m0d, &p0d, sizeof (double)) == 0 || signbit (m0d))
-          && !signbit (plus_inf)
-          && signbit (minus_inf)))
-      result |= 2;
-  }
-  if (signbit (vl)) /* link check */
-    vl++;
-  {
-    long double plus_inf = 1.0L / p0l;
-    long double minus_inf = -1.0L / p0l;
-    if (signbit (255.0L))
-      result |= 4;
-    if (!signbit (-255.0L))
-      result |= 4;
-    if (signbit (p0l))
-      result |= 8;
-    if (!(memcmp (&m0l, &p0l, sizeof (long double)) == 0 || signbit (m0l)))
-      result |= 16;
-    if (signbit (plus_inf))
-      result |= 32;
-    if (!signbit (minus_inf))
-      result |= 64;
-  }
-  return result;
-}
 
 
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
+
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS secure_getenv.$ac_objext"
+
+
+  ac_fn_c_check_func "$LINENO" "__secure_getenv" "ac_cv_func___secure_getenv"
+if test "x$ac_cv_func___secure_getenv" = xyes
 then :
-  gl_cv_func_signbit_builtins=yes
-else $as_nop
-  gl_cv_func_signbit_builtins=no
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
+  printf "%s\n" "#define HAVE___SECURE_GETENV 1" >>confdefs.h
+
 fi
 
+  if test $ac_cv_func___secure_getenv = no; then
+    ac_fn_c_check_func "$LINENO" "issetugid" "ac_cv_func_issetugid"
+if test "x$ac_cv_func_issetugid" = xyes
+then :
+  printf "%s\n" "#define HAVE_ISSETUGID 1" >>confdefs.h
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_signbit_builtins" >&5
-printf "%s\n" "$gl_cv_func_signbit_builtins" >&6; }
-      case "$gl_cv_func_signbit_builtins" in
-    *yes)
-      REPLACE_SIGNBIT_USING_BUILTINS=1
-      ;;
-    *)
-      case "$gl_cv_func_signbit" in
-        *yes) ;;
-        *)
-                    REPLACE_SIGNBIT=1
-          ;;
-      esac
-      ;;
-  esac
-          case "$host_os" in
-    solaris*)
-      REPLACE_SIGNBIT=1
-      ;;
-  esac
-  if test $REPLACE_SIGNBIT = 1; then
 
+  fi
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking where to find the sign bit in a 'float'" >&5
-printf %s "checking where to find the sign bit in a 'float'... " >&6; }
-if test ${gl_cv_cc_float_signbit+y}
+
+  fi
+
+
+
+
+
+
+
+
+
+          GL_M4_GNULIB_SECURE_GETENV=1
+
+
+
+
+
+printf "%s\n" "#define GNULIB_TEST_SECURE_GETENV 1" >>confdefs.h
+
+
+
+
+
+
+
+
+    NEED_SETLOCALE_IMPROVED=0
+  case "$host_os" in
+            mingw*) NEED_SETLOCALE_IMPROVED=1 ;;
+            cygwin*)
+      case `uname -r` in
+        1.5.*) NEED_SETLOCALE_IMPROVED=1 ;;
+      esac
+      ;;
+        *)
+      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether setlocale supports the C locale" >&5
+printf %s "checking whether setlocale supports the C locale... " >&6; }
+if test ${gl_cv_func_setlocale_works+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-
-      if test "$cross_compiling" = yes
+  if test "$cross_compiling" = yes
 then :
-
-                              gl_cv_cc_float_signbit="unknown"
+  case "$host_os" in
+                               # Guess no on Android.
+              linux*-android*) gl_cv_func_setlocale_works="guessing no";;
+                               # Guess yes otherwise.
+              *)               gl_cv_func_setlocale_works="guessing yes";;
+            esac
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
-#include <stddef.h>
-#include <stdio.h>
-#define NWORDS \
-  ((sizeof (float) + sizeof (unsigned int) - 1) / sizeof (unsigned int))
-typedef union { float value; unsigned int word[NWORDS]; }
-        memory_float;
-static memory_float plus = { 1.0f };
-static memory_float minus = { -1.0f };
+#include <locale.h>
 int main ()
 {
-  size_t j, k, i;
-  unsigned int m;
-  FILE *fp = fopen ("conftest.out", "w");
-  if (fp == NULL)
-    return 1;
-  /* Find the different bit.  */
-  k = 0; m = 0;
-  for (j = 0; j < NWORDS; j++)
-    {
-      unsigned int x = plus.word[j] ^ minus.word[j];
-      if ((x & (x - 1)) || (x && m))
-        {
-          /* More than one bit difference.  */
-          fprintf (fp, "unknown");
-          fclose (fp);
-          return 2;
-        }
-      if (x)
-        {
-          k = j;
-          m = x;
-        }
-    }
-  if (m == 0)
-    {
-      /* No difference.  */
-      fprintf (fp, "unknown");
-      fclose (fp);
-      return 3;
-    }
-  /* Now m = plus.word[k] ^ ~minus.word[k].  */
-  if (plus.word[k] & ~minus.word[k])
-    {
-      /* Oh? The sign bit is set in the positive and cleared in the negative
-         numbers?  */
-      fprintf (fp, "unknown");
-      fclose (fp);
-      return 4;
-    }
-  for (i = 0; ; i++)
-    if ((m >> i) & 1)
-      break;
-  fprintf (fp, "word %d bit %d", (int) k, (int) i);
-  if (fclose (fp) != 0)
-    return 5;
-  return 0;
+  return setlocale (LC_ALL, "C") == NULL;
 }
-
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_cc_float_signbit=`cat conftest.out`
+  gl_cv_func_setlocale_works=yes
 else $as_nop
-  gl_cv_cc_float_signbit="unknown"
+  gl_cv_func_setlocale_works=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
-      rm -f conftest.out
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_cc_float_signbit" >&5
-printf "%s\n" "$gl_cv_cc_float_signbit" >&6; }
-  case "$gl_cv_cc_float_signbit" in
-    word*bit*)
-      word=`echo "$gl_cv_cc_float_signbit" | sed -e 's/word //' -e 's/ bit.*//'`
-      bit=`echo "$gl_cv_cc_float_signbit" | sed -e 's/word.*bit //'`
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_setlocale_works" >&5
+printf "%s\n" "$gl_cv_func_setlocale_works" >&6; }
+      case "$gl_cv_func_setlocale_works" in
+        *yes) ;;
+        *) NEED_SETLOCALE_IMPROVED=1 ;;
+      esac
+      ;;
+  esac
 
-printf "%s\n" "#define FLT_SIGNBIT_WORD $word" >>confdefs.h
+printf "%s\n" "#define NEED_SETLOCALE_IMPROVED $NEED_SETLOCALE_IMPROVED" >>confdefs.h
 
 
-printf "%s\n" "#define FLT_SIGNBIT_BIT $bit" >>confdefs.h
+    NEED_SETLOCALE_MTSAFE=0
+  if test $SETLOCALE_NULL_ALL_MTSAFE = 0 || test $SETLOCALE_NULL_ONE_MTSAFE = 0; then
+    NEED_SETLOCALE_MTSAFE=1
+  fi
 
-      ;;
-  esac
+printf "%s\n" "#define NEED_SETLOCALE_MTSAFE $NEED_SETLOCALE_MTSAFE" >>confdefs.h
 
 
+  if test $NEED_SETLOCALE_IMPROVED = 1 || test $NEED_SETLOCALE_MTSAFE = 1; then
+    REPLACE_SETLOCALE=1
+  fi
 
+  if test $NEED_SETLOCALE_MTSAFE = 1; then
+    LIB_SETLOCALE="$LIB_SETLOCALE_NULL"
+  else
+    LIB_SETLOCALE=
+  fi
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking where to find the sign bit in a 'double'" >&5
-printf %s "checking where to find the sign bit in a 'double'... " >&6; }
-if test ${gl_cv_cc_double_signbit+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-      if test "$cross_compiling" = yes
-then :
+  if test $REPLACE_SETLOCALE = 1; then
 
-                              gl_cv_cc_double_signbit="unknown"
 
-else $as_nop
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
 
-#include <stddef.h>
-#include <stdio.h>
-#define NWORDS \
-  ((sizeof (double) + sizeof (unsigned int) - 1) / sizeof (unsigned int))
-typedef union { double value; unsigned int word[NWORDS]; }
-        memory_float;
-static memory_float plus = { 1.0 };
-static memory_float minus = { -1.0 };
-int main ()
-{
-  size_t j, k, i;
-  unsigned int m;
-  FILE *fp = fopen ("conftest.out", "w");
-  if (fp == NULL)
-    return 1;
-  /* Find the different bit.  */
-  k = 0; m = 0;
-  for (j = 0; j < NWORDS; j++)
-    {
-      unsigned int x = plus.word[j] ^ minus.word[j];
-      if ((x & (x - 1)) || (x && m))
-        {
-          /* More than one bit difference.  */
-          fprintf (fp, "unknown");
-          fclose (fp);
-          return 2;
-        }
-      if (x)
-        {
-          k = j;
-          m = x;
-        }
-    }
-  if (m == 0)
-    {
-      /* No difference.  */
-      fprintf (fp, "unknown");
-      fclose (fp);
-      return 3;
-    }
-  /* Now m = plus.word[k] ^ ~minus.word[k].  */
-  if (plus.word[k] & ~minus.word[k])
-    {
-      /* Oh? The sign bit is set in the positive and cleared in the negative
-         numbers?  */
-      fprintf (fp, "unknown");
-      fclose (fp);
-      return 4;
-    }
-  for (i = 0; ; i++)
-    if ((m >> i) & 1)
-      break;
-  fprintf (fp, "word %d bit %d", (int) k, (int) i);
-  if (fclose (fp) != 0)
-    return 5;
-  return 0;
-}
 
-_ACEOF
-if ac_fn_c_try_run "$LINENO"
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS setlocale.$ac_objext"
+
+
+        :
+
+  fi
+
+
+
+
+
+
+
+
+
+          GL_M4_GNULIB_SETLOCALE=1
+
+
+
+
+
+printf "%s\n" "#define GNULIB_TEST_SETLOCALE 1" >>confdefs.h
+
+
+
+
+
+
+
+
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether setlocale (LC_ALL, NULL) is multithread-safe" >&5
+printf %s "checking whether setlocale (LC_ALL, NULL) is multithread-safe... " >&6; }
+if test ${gl_cv_func_setlocale_null_all_mtsafe+y}
 then :
-  gl_cv_cc_double_signbit=`cat conftest.out`
+  printf %s "(cached) " >&6
 else $as_nop
-  gl_cv_cc_double_signbit="unknown"
-fi
-rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
-  conftest.$ac_objext conftest.beam conftest.$ac_ext
-fi
-
-      rm -f conftest.out
+  case "$host_os" in
+       # Guess no on musl libc, macOS, FreeBSD, NetBSD, OpenBSD, AIX, Haiku, Cygwin.
+       *-musl* | darwin* | freebsd* | midnightbsd* | netbsd* | openbsd* | aix* | haiku* | cygwin*)
+         gl_cv_func_setlocale_null_all_mtsafe=no ;;
+       # Guess yes on glibc, HP-UX, IRIX, Solaris, native Windows.
+       *-gnu* | gnu* | hpux* | irix* | solaris* | mingw*)
+         gl_cv_func_setlocale_null_all_mtsafe=yes ;;
+       # If we don't know, obey --enable-cross-guesses.
+       *)
+         gl_cv_func_setlocale_null_all_mtsafe="$gl_cross_guess_normal" ;;
+     esac
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_cc_double_signbit" >&5
-printf "%s\n" "$gl_cv_cc_double_signbit" >&6; }
-  case "$gl_cv_cc_double_signbit" in
-    word*bit*)
-      word=`echo "$gl_cv_cc_double_signbit" | sed -e 's/word //' -e 's/ bit.*//'`
-      bit=`echo "$gl_cv_cc_double_signbit" | sed -e 's/word.*bit //'`
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_setlocale_null_all_mtsafe" >&5
+printf "%s\n" "$gl_cv_func_setlocale_null_all_mtsafe" >&6; }
+    case "$host_os" in
+    mingw*) ;;
+    *)
+      if test $gl_pthread_api = no && test $ac_cv_header_threads_h = no; then
+        gl_cv_func_setlocale_null_all_mtsafe="trivially yes"
+      fi
+      ;;
+  esac
+  case "$gl_cv_func_setlocale_null_all_mtsafe" in
+    *yes) SETLOCALE_NULL_ALL_MTSAFE=1 ;;
+    *)    SETLOCALE_NULL_ALL_MTSAFE=0 ;;
+  esac
 
-printf "%s\n" "#define DBL_SIGNBIT_WORD $word" >>confdefs.h
+printf "%s\n" "#define SETLOCALE_NULL_ALL_MTSAFE $SETLOCALE_NULL_ALL_MTSAFE" >>confdefs.h
 
 
-printf "%s\n" "#define DBL_SIGNBIT_BIT $bit" >>confdefs.h
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether setlocale (category, NULL) is multithread-safe" >&5
+printf %s "checking whether setlocale (category, NULL) is multithread-safe... " >&6; }
+if test ${gl_cv_func_setlocale_null_one_mtsafe+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  case "$host_os" in
+       # Guess no on OpenBSD, AIX.
+       openbsd* | aix*)
+         gl_cv_func_setlocale_null_one_mtsafe=no ;;
+       # Guess yes on glibc, musl libc, macOS, FreeBSD, NetBSD, HP-UX, IRIX, Solaris, Haiku, Cygwin, native Windows.
+       *-gnu* | gnu* | *-musl* | darwin* | freebsd* | midnightbsd* | netbsd* | hpux* | irix* | solaris* | haiku* | cygwin* | mingw*)
+         gl_cv_func_setlocale_null_one_mtsafe=yes ;;
+       # If we don't know, obey --enable-cross-guesses.
+       *)
+         gl_cv_func_setlocale_null_one_mtsafe="$gl_cross_guess_normal" ;;
+     esac
 
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_setlocale_null_one_mtsafe" >&5
+printf "%s\n" "$gl_cv_func_setlocale_null_one_mtsafe" >&6; }
+    case "$host_os" in
+    mingw*) ;;
+    *)
+      if test $gl_pthread_api = no && test $ac_cv_header_threads_h = no; then
+        gl_cv_func_setlocale_null_one_mtsafe="trivially yes"
+      fi
       ;;
   esac
+  case "$gl_cv_func_setlocale_null_one_mtsafe" in
+    *yes) SETLOCALE_NULL_ONE_MTSAFE=1 ;;
+    *)    SETLOCALE_NULL_ONE_MTSAFE=0 ;;
+  esac
+
+printf "%s\n" "#define SETLOCALE_NULL_ONE_MTSAFE $SETLOCALE_NULL_ONE_MTSAFE" >>confdefs.h
 
 
+    if test $SETLOCALE_NULL_ALL_MTSAFE = 0 || test $SETLOCALE_NULL_ONE_MTSAFE = 0; then
+    case "$host_os" in
+      mingw*) LIB_SETLOCALE_NULL= ;;
+      *)
 
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking where to find the sign bit in a 'long double'" >&5
-printf %s "checking where to find the sign bit in a 'long double'... " >&6; }
-if test ${gl_cv_cc_long_double_signbit+y}
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether imported symbols can be declared weak" >&5
+printf %s "checking whether imported symbols can be declared weak... " >&6; }
+if test ${gl_cv_have_weak+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
+  gl_cv_have_weak=no
+          cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+extern void xyzzy ();
+#pragma weak xyzzy
+int
+main (void)
+{
+xyzzy();
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"
+then :
+  gl_cv_have_weak=maybe
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+     if test $gl_cv_have_weak = maybe; then
+                     if test "$cross_compiling" = yes
+then :
+                      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#ifdef __ELF__
+             Extensible Linking Format
+             #endif
 
-      if test "$cross_compiling" = yes
+_ACEOF
+if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
+  $EGREP "Extensible Linking Format" >/dev/null 2>&1
 then :
+  gl_cv_have_weak="guessing yes"
+else $as_nop
+  gl_cv_have_weak="guessing no"
+fi
+rm -rf conftest*
 
-                              gl_cv_cc_long_double_signbit="unknown"
 
 else $as_nop
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
-#include <stddef.h>
 #include <stdio.h>
-#define NWORDS \
-  ((sizeof (long double) + sizeof (unsigned int) - 1) / sizeof (unsigned int))
-typedef union { long double value; unsigned int word[NWORDS]; }
-        memory_float;
-static memory_float plus = { 1.0L };
-static memory_float minus = { -1.0L };
+#pragma weak fputs
 int main ()
 {
-  size_t j, k, i;
-  unsigned int m;
-  FILE *fp = fopen ("conftest.out", "w");
-  if (fp == NULL)
-    return 1;
-  /* Find the different bit.  */
-  k = 0; m = 0;
-  for (j = 0; j < NWORDS; j++)
-    {
-      unsigned int x = plus.word[j] ^ minus.word[j];
-      if ((x & (x - 1)) || (x && m))
-        {
-          /* More than one bit difference.  */
-          fprintf (fp, "unknown");
-          fclose (fp);
-          return 2;
-        }
-      if (x)
-        {
-          k = j;
-          m = x;
-        }
-    }
-  if (m == 0)
-    {
-      /* No difference.  */
-      fprintf (fp, "unknown");
-      fclose (fp);
-      return 3;
-    }
-  /* Now m = plus.word[k] ^ ~minus.word[k].  */
-  if (plus.word[k] & ~minus.word[k])
-    {
-      /* Oh? The sign bit is set in the positive and cleared in the negative
-         numbers?  */
-      fprintf (fp, "unknown");
-      fclose (fp);
-      return 4;
-    }
-  for (i = 0; ; i++)
-    if ((m >> i) & 1)
-      break;
-  fprintf (fp, "word %d bit %d", (int) k, (int) i);
-  if (fclose (fp) != 0)
-    return 5;
-  return 0;
+  return (fputs == NULL);
 }
-
 _ACEOF
 if ac_fn_c_try_run "$LINENO"
 then :
-  gl_cv_cc_long_double_signbit=`cat conftest.out`
+  gl_cv_have_weak=yes
 else $as_nop
-  gl_cv_cc_long_double_signbit="unknown"
+  gl_cv_have_weak=no
 fi
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
   conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
-      rm -f conftest.out
+     fi
+          case " $LDFLAGS " in
+       *" -static "*) gl_cv_have_weak=no ;;
+     esac
+                    case "$gl_cv_have_weak" in
+       *yes)
+         case "$host_os" in
+           freebsd* | dragonfly* | midnightbsd*)
+             : > conftest1.c
+             $CC $CPPFLAGS $CFLAGS $LDFLAGS -fPIC -shared -o libempty.so conftest1.c -lpthread >&5 2>&1
+             cat <<EOF > conftest2.c
+#include <pthread.h>
+#pragma weak pthread_mutexattr_gettype
+int main ()
+{
+  return (pthread_mutexattr_gettype != NULL);
+}
+EOF
+             $CC $CPPFLAGS $CFLAGS $LDFLAGS -o conftest conftest2.c libempty.so >&5 2>&1 \
+               || gl_cv_have_weak=no
+             rm -f conftest1.c libempty.so conftest2.c conftest
+             ;;
+         esac
+         ;;
+     esac
+
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_have_weak" >&5
+printf "%s\n" "$gl_cv_have_weak" >&6; }
+  case "$gl_cv_have_weak" in
+    *yes)
+
+printf "%s\n" "#define HAVE_WEAK_SYMBOLS 1" >>confdefs.h
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_cc_long_double_signbit" >&5
-printf "%s\n" "$gl_cv_cc_long_double_signbit" >&6; }
-  case "$gl_cv_cc_long_double_signbit" in
-    word*bit*)
-      word=`echo "$gl_cv_cc_long_double_signbit" | sed -e 's/word //' -e 's/ bit.*//'`
-      bit=`echo "$gl_cv_cc_long_double_signbit" | sed -e 's/word.*bit //'`
+      ;;
+  esac
 
-printf "%s\n" "#define LDBL_SIGNBIT_WORD $word" >>confdefs.h
+        case "$gl_cv_have_weak" in
+          *yes) LIB_SETLOCALE_NULL= ;;
+          *)    LIB_SETLOCALE_NULL="$LIBPTHREAD" ;;
+        esac
+        ;;
+    esac
+  else
+    LIB_SETLOCALE_NULL=
+  fi
 
 
-printf "%s\n" "#define LDBL_SIGNBIT_BIT $bit" >>confdefs.h
+  if test $SETLOCALE_NULL_ALL_MTSAFE = 0 || test $SETLOCALE_NULL_ONE_MTSAFE = 0; then
 
-      ;;
-  esac
 
 
-    if test "$gl_cv_cc_float_signbit" = unknown; then
-            ac_fn_check_decl "$LINENO" "copysignf" "ac_cv_have_decl_copysignf" "#include <math.h>
-" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_copysignf" = xyes
-then :
-  ac_have_decl=1
-else $as_nop
-  ac_have_decl=0
-fi
-printf "%s\n" "#define HAVE_DECL_COPYSIGNF $ac_have_decl" >>confdefs.h
 
-      if test "$ac_cv_have_decl_copysignf" = yes; then
-                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether copysignf can be used without linking with libm" >&5
-printf %s "checking whether copysignf can be used without linking with libm... " >&6; }
-if test ${gl_cv_func_copysignf_no_libm+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
 
-            cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <math.h>
-                   float x, y;
-int
-main (void)
-{
-return copysignf (x, y) < 0;
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_link "$LINENO"
-then :
-  gl_cv_func_copysignf_no_libm=yes
-else $as_nop
-  gl_cv_func_copysignf_no_libm=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
 
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_copysignf_no_libm" >&5
-printf "%s\n" "$gl_cv_func_copysignf_no_libm" >&6; }
-        if test $gl_cv_func_copysignf_no_libm = yes; then
 
-printf "%s\n" "#define HAVE_COPYSIGNF_IN_LIBC 1" >>confdefs.h
 
-        fi
-      fi
-    fi
-    if test "$gl_cv_cc_double_signbit" = unknown; then
-            ac_fn_check_decl "$LINENO" "copysign" "ac_cv_have_decl_copysign" "#include <math.h>
-" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_copysign" = xyes
-then :
-  ac_have_decl=1
-else $as_nop
-  ac_have_decl=0
-fi
-printf "%s\n" "#define HAVE_DECL_COPYSIGN $ac_have_decl" >>confdefs.h
+  M4_LIBOBJS="$M4_LIBOBJS setlocale-lock.$ac_objext"
 
-      if test "$ac_cv_have_decl_copysign" = yes; then
-                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether copysign can be used without linking with libm" >&5
-printf %s "checking whether copysign can be used without linking with libm... " >&6; }
-if test ${gl_cv_func_copysign_no_libm+y}
+
+
+
+  CFLAG_VISIBILITY=
+  HAVE_VISIBILITY=0
+  if test -n "$GCC"; then
+                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether the -Werror option is usable" >&5
+printf %s "checking whether the -Werror option is usable... " >&6; }
+if test ${gl_cv_cc_vis_werror+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-
-            cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  gl_save_CFLAGS="$CFLAGS"
+       CFLAGS="$CFLAGS -Werror"
+       cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <math.h>
-                   double x, y;
+
 int
 main (void)
 {
-return copysign (x, y) < 0;
+
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"
+if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_func_copysign_no_libm=yes
+  gl_cv_cc_vis_werror=yes
 else $as_nop
-  gl_cv_func_copysign_no_libm=no
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
-
+  gl_cv_cc_vis_werror=no
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_copysign_no_libm" >&5
-printf "%s\n" "$gl_cv_func_copysign_no_libm" >&6; }
-        if test $gl_cv_func_copysign_no_libm = yes; then
-
-printf "%s\n" "#define HAVE_COPYSIGN_IN_LIBC 1" >>confdefs.h
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+       CFLAGS="$gl_save_CFLAGS"
 
-        fi
-      fi
-    fi
-    if test "$gl_cv_cc_long_double_signbit" = unknown; then
-            ac_fn_check_decl "$LINENO" "copysignl" "ac_cv_have_decl_copysignl" "#include <math.h>
-" "$ac_c_undeclared_builtin_options" "CFLAGS"
-if test "x$ac_cv_have_decl_copysignl" = xyes
-then :
-  ac_have_decl=1
-else $as_nop
-  ac_have_decl=0
 fi
-printf "%s\n" "#define HAVE_DECL_COPYSIGNL $ac_have_decl" >>confdefs.h
-
-      if test "$ac_cv_have_decl_copysignl" = yes; then
-                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether copysignl can be used without linking with libm" >&5
-printf %s "checking whether copysignl can be used without linking with libm... " >&6; }
-if test ${gl_cv_func_copysignl_no_libm+y}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_cc_vis_werror" >&5
+printf "%s\n" "$gl_cv_cc_vis_werror" >&6; }
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for simple visibility declarations" >&5
+printf %s "checking for simple visibility declarations... " >&6; }
+if test ${gl_cv_cc_visibility+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-
-            cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+  gl_save_CFLAGS="$CFLAGS"
+       CFLAGS="$CFLAGS -fvisibility=hidden"
+                                          if test $gl_cv_cc_vis_werror = yes; then
+         CFLAGS="$CFLAGS -Werror"
+       fi
+       cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <math.h>
-                   long double x, y;
+extern __attribute__((__visibility__("hidden"))) int hiddenvar;
+              extern __attribute__((__visibility__("default"))) int exportedvar;
+              extern __attribute__((__visibility__("hidden"))) int hiddenfunc (void);
+              extern __attribute__((__visibility__("default"))) int exportedfunc (void);
+              void dummyfunc (void);
+              void dummyfunc (void) {}
+
 int
 main (void)
 {
-return copysignl (x, y) < 0;
+
   ;
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"
+if ac_fn_c_try_compile "$LINENO"
 then :
-  gl_cv_func_copysignl_no_libm=yes
+  gl_cv_cc_visibility=yes
 else $as_nop
-  gl_cv_func_copysignl_no_libm=no
+  gl_cv_cc_visibility=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
-    conftest$ac_exeext conftest.$ac_ext
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+       CFLAGS="$gl_save_CFLAGS"
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_copysignl_no_libm" >&5
-printf "%s\n" "$gl_cv_func_copysignl_no_libm" >&6; }
-        if test $gl_cv_func_copysignl_no_libm = yes; then
-
-printf "%s\n" "#define HAVE_COPYSIGNL_IN_LIBC 1" >>confdefs.h
-
-        fi
-      fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_cc_visibility" >&5
+printf "%s\n" "$gl_cv_cc_visibility" >&6; }
+    if test $gl_cv_cc_visibility = yes; then
+      CFLAG_VISIBILITY="-fvisibility=hidden"
+      HAVE_VISIBILITY=1
     fi
   fi
 
-  if test $REPLACE_SIGNBIT = 1; then
-
-
-
-
-
 
 
+printf "%s\n" "#define HAVE_VISIBILITY $HAVE_VISIBILITY" >>confdefs.h
 
-  M4_LIBOBJS="$M4_LIBOBJS signbitf.$ac_objext"
 
 
+  fi
 
 
 
@@ -45641,55 +45398,76 @@
 
 
 
-  M4_LIBOBJS="$M4_LIBOBJS signbitd.$ac_objext"
 
 
+          GL_M4_GNULIB_SETLOCALE_NULL=1
 
 
 
 
 
+printf "%s\n" "#define GNULIB_TEST_SETLOCALE_NULL 1" >>confdefs.h
 
 
-  M4_LIBOBJS="$M4_LIBOBJS signbitl.$ac_objext"
 
-  fi
 
 
 
 
 
 
+  if test $ac_cv_func_sigaction = yes; then
+    ac_fn_c_check_member "$LINENO" "struct sigaction" "sa_sigaction" "ac_cv_member_struct_sigaction_sa_sigaction" "#include <signal.h>
+"
+if test "x$ac_cv_member_struct_sigaction_sa_sigaction" = xyes
+then :
 
+printf "%s\n" "#define HAVE_STRUCT_SIGACTION_SA_SIGACTION 1" >>confdefs.h
 
 
-          GL_M4_GNULIB_SIGNBIT=1
+fi
 
+    if test $ac_cv_member_struct_sigaction_sa_sigaction = no; then
+      HAVE_STRUCT_SIGACTION_SA_SIGACTION=0
+    fi
+  else
+    HAVE_SIGACTION=0
+  fi
 
+  if test $HAVE_SIGACTION = 0; then
 
 
 
-printf "%s\n" "#define GNULIB_TEST_SIGNBIT 1" >>confdefs.h
 
 
 
 
 
+  M4_LIBOBJS="$M4_LIBOBJS sigaction.$ac_objext"
 
 
 
-printf "%s\n" "#define GNULIB_SIGPIPE 1" >>confdefs.h
 
 
 
 
+  ac_fn_c_check_type "$LINENO" "siginfo_t" "ac_cv_type_siginfo_t" "
+#include <signal.h>
 
+"
+if test "x$ac_cv_type_siginfo_t" = xyes
+then :
 
+printf "%s\n" "#define HAVE_SIGINFO_T 1" >>confdefs.h
 
 
-  GL_M4_GNULIB_SIGNAL_H_SIGPIPE=1
+fi
 
+  if test $ac_cv_type_siginfo_t = no; then
+    HAVE_SIGINFO_T=0
+  fi
 
+  fi
 
 
 
@@ -45697,647 +45475,799 @@
 
 
 
-  GL_M4_GNULIB_STDIO_H_SIGPIPE=1
 
 
+          GL_M4_GNULIB_SIGACTION=1
 
 
 
 
 
+printf "%s\n" "#define GNULIB_TEST_SIGACTION 1" >>confdefs.h
 
-  GL_M4_GNULIB_UNISTD_H_SIGPIPE=1
 
 
 
 
 
-  HAVE_POSIX_SIGNALBLOCKING=0
-  if test "$gl_cv_type_sigset_t" = yes; then
-    ac_fn_c_check_func "$LINENO" "sigprocmask" "ac_cv_func_sigprocmask"
-if test "x$ac_cv_func_sigprocmask" = xyes
-then :
-  HAVE_POSIX_SIGNALBLOCKING=1
-fi
 
-  fi
 
-  if test $HAVE_POSIX_SIGNALBLOCKING = 0; then
 
 
 
 
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for signbit macro" >&5
+printf %s "checking for signbit macro... " >&6; }
+if test ${gl_cv_func_signbit+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
+      if test "$cross_compiling" = yes
+then :
+  case "$host_os" in
+                          # Guess yes on glibc systems.
+           *-gnu* | gnu*) gl_cv_func_signbit="guessing yes" ;;
+                          # Guess yes on musl systems.
+           *-musl*)       gl_cv_func_signbit="guessing yes" ;;
+                          # Guess yes on native Windows.
+           mingw*)        gl_cv_func_signbit="guessing yes" ;;
+                          # If we don't know, obey --enable-cross-guesses.
+           *)             gl_cv_func_signbit="$gl_cross_guess_normal" ;;
+         esac
 
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
+#include <math.h>
+/* If signbit is defined as a function, don't use it, since calling it for
+   'float' or 'long double' arguments would involve conversions.
+   If signbit is not declared at all but exists as a library function, don't
+   use it, since the prototype may not match.
+   If signbit is not declared at all but exists as a compiler built-in, don't
+   use it, since it's preferable to use __builtin_signbit* (no warnings,
+   no conversions).  */
+#ifndef signbit
+# error "signbit should be a macro"
+#endif
+#include <string.h>
 
-  M4_LIBOBJS="$M4_LIBOBJS sigprocmask.$ac_objext"
+/* Global variables.
+   Needed because GCC 4 constant-folds __builtin_signbitl (literal)
+   but cannot constant-fold            __builtin_signbitl (variable).  */
+float vf;
+double vd;
+long double vl;
+int main ()
+{
+/* HP cc on HP-UX 10.20 has a bug with the constant expression -0.0.
+   So we use -p0f and -p0d instead.  */
+float p0f = 0.0f;
+float m0f = -p0f;
+double p0d = 0.0;
+double m0d = -p0d;
+/* On HP-UX 10.20, negating 0.0L does not yield -0.0L.
+   So we use another constant expression instead.
+   But that expression does not work on other platforms, such as when
+   cross-compiling to PowerPC on Mac OS X 10.5.  */
+long double p0l = 0.0L;
+#if defined __hpux || defined __sgi
+long double m0l = -LDBL_MIN * LDBL_MIN;
+#else
+long double m0l = -p0l;
+#endif
+  int result = 0;
+  if (signbit (vf)) /* link check */
+    vf++;
+  {
+    float plus_inf = 1.0f / p0f;
+    float minus_inf = -1.0f / p0f;
+    if (!(!signbit (255.0f)
+          && signbit (-255.0f)
+          && !signbit (p0f)
+          && (memcmp (&m0f, &p0f, sizeof (float)) == 0 || signbit (m0f))
+          && !signbit (plus_inf)
+          && signbit (minus_inf)))
+      result |= 1;
+  }
+  if (signbit (vd)) /* link check */
+    vd++;
+  {
+    double plus_inf = 1.0 / p0d;
+    double minus_inf = -1.0 / p0d;
+    if (!(!signbit (255.0)
+          && signbit (-255.0)
+          && !signbit (p0d)
+          && (memcmp (&m0d, &p0d, sizeof (double)) == 0 || signbit (m0d))
+          && !signbit (plus_inf)
+          && signbit (minus_inf)))
+      result |= 2;
+  }
+  if (signbit (vl)) /* link check */
+    vl++;
+  {
+    long double plus_inf = 1.0L / p0l;
+    long double minus_inf = -1.0L / p0l;
+    if (signbit (255.0L))
+      result |= 4;
+    if (!signbit (-255.0L))
+      result |= 4;
+    if (signbit (p0l))
+      result |= 8;
+    if (!(memcmp (&m0l, &p0l, sizeof (long double)) == 0 || signbit (m0l)))
+      result |= 16;
+    if (signbit (plus_inf))
+      result |= 32;
+    if (!signbit (minus_inf))
+      result |= 64;
+  }
+  return result;
+}
 
-    :
-  fi
 
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
+then :
+  gl_cv_func_signbit=yes
+else $as_nop
+  gl_cv_func_signbit=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
 
 
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_signbit" >&5
+printf "%s\n" "$gl_cv_func_signbit" >&6; }
+          { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for signbit compiler built-ins" >&5
+printf %s "checking for signbit compiler built-ins... " >&6; }
+if test ${gl_cv_func_signbit_builtins+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
+      if test "$cross_compiling" = yes
+then :
+  case "$host_os" in
+                          # Guess yes on glibc systems.
+           *-gnu* | gnu*) gl_cv_func_signbit_builtins="guessing yes" ;;
+                          # Guess yes on musl systems.
+           *-musl*)       gl_cv_func_signbit_builtins="guessing yes" ;;
+                          # Guess yes on mingw, no on MSVC.
+           mingw*)        if test -n "$GCC"; then
+                            gl_cv_func_signbit_builtins="guessing yes"
+                          else
+                            gl_cv_func_signbit_builtins="guessing no"
+                          fi
+                          ;;
+                          # If we don't know, obey --enable-cross-guesses.
+           *)             gl_cv_func_signbit_builtins="$gl_cross_guess_normal" ;;
+         esac
 
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
+#if (__GNUC__ >= 4) || (__clang_major__ >= 4)
+# define signbit(x) \
+   (sizeof (x) == sizeof (long double) ? __builtin_signbitl (x) : \
+    sizeof (x) == sizeof (double) ? __builtin_signbit (x) : \
+    __builtin_signbitf (x))
+#else
+# error "signbit should be three compiler built-ins"
+#endif
+#include <string.h>
 
+/* Global variables.
+   Needed because GCC 4 constant-folds __builtin_signbitl (literal)
+   but cannot constant-fold            __builtin_signbitl (variable).  */
+float vf;
+double vd;
+long double vl;
+int main ()
+{
+/* HP cc on HP-UX 10.20 has a bug with the constant expression -0.0.
+   So we use -p0f and -p0d instead.  */
+float p0f = 0.0f;
+float m0f = -p0f;
+double p0d = 0.0;
+double m0d = -p0d;
+/* On HP-UX 10.20, negating 0.0L does not yield -0.0L.
+   So we use another constant expression instead.
+   But that expression does not work on other platforms, such as when
+   cross-compiling to PowerPC on Mac OS X 10.5.  */
+long double p0l = 0.0L;
+#if defined __hpux || defined __sgi
+long double m0l = -LDBL_MIN * LDBL_MIN;
+#else
+long double m0l = -p0l;
+#endif
+  int result = 0;
+  if (signbit (vf)) /* link check */
+    vf++;
+  {
+    float plus_inf = 1.0f / p0f;
+    float minus_inf = -1.0f / p0f;
+    if (!(!signbit (255.0f)
+          && signbit (-255.0f)
+          && !signbit (p0f)
+          && (memcmp (&m0f, &p0f, sizeof (float)) == 0 || signbit (m0f))
+          && !signbit (plus_inf)
+          && signbit (minus_inf)))
+      result |= 1;
+  }
+  if (signbit (vd)) /* link check */
+    vd++;
+  {
+    double plus_inf = 1.0 / p0d;
+    double minus_inf = -1.0 / p0d;
+    if (!(!signbit (255.0)
+          && signbit (-255.0)
+          && !signbit (p0d)
+          && (memcmp (&m0d, &p0d, sizeof (double)) == 0 || signbit (m0d))
+          && !signbit (plus_inf)
+          && signbit (minus_inf)))
+      result |= 2;
+  }
+  if (signbit (vl)) /* link check */
+    vl++;
+  {
+    long double plus_inf = 1.0L / p0l;
+    long double minus_inf = -1.0L / p0l;
+    if (signbit (255.0L))
+      result |= 4;
+    if (!signbit (-255.0L))
+      result |= 4;
+    if (signbit (p0l))
+      result |= 8;
+    if (!(memcmp (&m0l, &p0l, sizeof (long double)) == 0 || signbit (m0l)))
+      result |= 16;
+    if (signbit (plus_inf))
+      result |= 32;
+    if (!signbit (minus_inf))
+      result |= 64;
+  }
+  return result;
+}
 
 
-          GL_M4_GNULIB_SIGPROCMASK=1
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
+then :
+  gl_cv_func_signbit_builtins=yes
+else $as_nop
+  gl_cv_func_signbit_builtins=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
 
 
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_signbit_builtins" >&5
+printf "%s\n" "$gl_cv_func_signbit_builtins" >&6; }
+      case "$gl_cv_func_signbit_builtins" in
+    *yes)
+      REPLACE_SIGNBIT_USING_BUILTINS=1
+      ;;
+    *)
+      case "$gl_cv_func_signbit" in
+        *yes) ;;
+        *)
+                    REPLACE_SIGNBIT=1
+          ;;
+      esac
+      ;;
+  esac
+          case "$host_os" in
+    solaris*)
+      REPLACE_SIGNBIT=1
+      ;;
+  esac
+  if test $REPLACE_SIGNBIT = 1; then
 
 
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking where to find the sign bit in a 'float'" >&5
+printf %s "checking where to find the sign bit in a 'float'... " >&6; }
+if test ${gl_cv_cc_float_signbit+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
-printf "%s\n" "#define GNULIB_TEST_SIGPROCMASK 1" >>confdefs.h
+      if test "$cross_compiling" = yes
+then :
 
+                              gl_cv_cc_float_signbit="unknown"
 
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
+#include <stddef.h>
+#include <stdio.h>
+#define NWORDS \
+  ((sizeof (float) + sizeof (unsigned int) - 1) / sizeof (unsigned int))
+typedef union { float value; unsigned int word[NWORDS]; }
+        memory_float;
+static memory_float plus = { 1.0f };
+static memory_float minus = { -1.0f };
+int main ()
+{
+  size_t j, k, i;
+  unsigned int m;
+  FILE *fp = fopen ("conftest.out", "w");
+  if (fp == NULL)
+    return 1;
+  /* Find the different bit.  */
+  k = 0; m = 0;
+  for (j = 0; j < NWORDS; j++)
+    {
+      unsigned int x = plus.word[j] ^ minus.word[j];
+      if ((x & (x - 1)) || (x && m))
+        {
+          /* More than one bit difference.  */
+          fprintf (fp, "unknown");
+          fclose (fp);
+          return 2;
+        }
+      if (x)
+        {
+          k = j;
+          m = x;
+        }
+    }
+  if (m == 0)
+    {
+      /* No difference.  */
+      fprintf (fp, "unknown");
+      fclose (fp);
+      return 3;
+    }
+  /* Now m = plus.word[k] ^ ~minus.word[k].  */
+  if (plus.word[k] & ~minus.word[k])
+    {
+      /* Oh? The sign bit is set in the positive and cleared in the negative
+         numbers?  */
+      fprintf (fp, "unknown");
+      fclose (fp);
+      return 4;
+    }
+  for (i = 0; ; i++)
+    if ((m >> i) & 1)
+      break;
+  fprintf (fp, "word %d bit %d", (int) k, (int) i);
+  if (fclose (fp) != 0)
+    return 5;
+  return 0;
+}
 
-# Check whether --with-libsigsegv was given.
-if test ${with_libsigsegv+y}
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
 then :
-  withval=$with_libsigsegv;
+  gl_cv_cc_float_signbit=`cat conftest.out`
+else $as_nop
+  gl_cv_cc_float_signbit="unknown"
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
 
-  SIGSEGV_H=sigsegv.h
-  if test "$with_libsigsegv" = yes; then
-
+      rm -f conftest.out
 
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_cc_float_signbit" >&5
+printf "%s\n" "$gl_cv_cc_float_signbit" >&6; }
+  case "$gl_cv_cc_float_signbit" in
+    word*bit*)
+      word=`echo "$gl_cv_cc_float_signbit" | sed -e 's/word //' -e 's/ bit.*//'`
+      bit=`echo "$gl_cv_cc_float_signbit" | sed -e 's/word.*bit //'`
 
+printf "%s\n" "#define FLT_SIGNBIT_WORD $word" >>confdefs.h
 
 
+printf "%s\n" "#define FLT_SIGNBIT_BIT $bit" >>confdefs.h
 
+      ;;
+  esac
 
 
 
 
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking where to find the sign bit in a 'double'" >&5
+printf %s "checking where to find the sign bit in a 'double'... " >&6; }
+if test ${gl_cv_cc_double_signbit+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
+      if test "$cross_compiling" = yes
+then :
 
+                              gl_cv_cc_double_signbit="unknown"
 
-    use_additional=yes
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
-  acl_save_prefix="$prefix"
-  prefix="$acl_final_prefix"
-  acl_save_exec_prefix="$exec_prefix"
-  exec_prefix="$acl_final_exec_prefix"
+#include <stddef.h>
+#include <stdio.h>
+#define NWORDS \
+  ((sizeof (double) + sizeof (unsigned int) - 1) / sizeof (unsigned int))
+typedef union { double value; unsigned int word[NWORDS]; }
+        memory_float;
+static memory_float plus = { 1.0 };
+static memory_float minus = { -1.0 };
+int main ()
+{
+  size_t j, k, i;
+  unsigned int m;
+  FILE *fp = fopen ("conftest.out", "w");
+  if (fp == NULL)
+    return 1;
+  /* Find the different bit.  */
+  k = 0; m = 0;
+  for (j = 0; j < NWORDS; j++)
+    {
+      unsigned int x = plus.word[j] ^ minus.word[j];
+      if ((x & (x - 1)) || (x && m))
+        {
+          /* More than one bit difference.  */
+          fprintf (fp, "unknown");
+          fclose (fp);
+          return 2;
+        }
+      if (x)
+        {
+          k = j;
+          m = x;
+        }
+    }
+  if (m == 0)
+    {
+      /* No difference.  */
+      fprintf (fp, "unknown");
+      fclose (fp);
+      return 3;
+    }
+  /* Now m = plus.word[k] ^ ~minus.word[k].  */
+  if (plus.word[k] & ~minus.word[k])
+    {
+      /* Oh? The sign bit is set in the positive and cleared in the negative
+         numbers?  */
+      fprintf (fp, "unknown");
+      fclose (fp);
+      return 4;
+    }
+  for (i = 0; ; i++)
+    if ((m >> i) & 1)
+      break;
+  fprintf (fp, "word %d bit %d", (int) k, (int) i);
+  if (fclose (fp) != 0)
+    return 5;
+  return 0;
+}
 
-    eval additional_includedir=\"$includedir\"
-    eval additional_libdir=\"$libdir\"
-    eval additional_libdir2=\"$exec_prefix/$acl_libdirstem2\"
-    eval additional_libdir3=\"$exec_prefix/$acl_libdirstem3\"
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
+then :
+  gl_cv_cc_double_signbit=`cat conftest.out`
+else $as_nop
+  gl_cv_cc_double_signbit="unknown"
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
 
-  exec_prefix="$acl_save_exec_prefix"
-  prefix="$acl_save_prefix"
+      rm -f conftest.out
 
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_cc_double_signbit" >&5
+printf "%s\n" "$gl_cv_cc_double_signbit" >&6; }
+  case "$gl_cv_cc_double_signbit" in
+    word*bit*)
+      word=`echo "$gl_cv_cc_double_signbit" | sed -e 's/word //' -e 's/ bit.*//'`
+      bit=`echo "$gl_cv_cc_double_signbit" | sed -e 's/word.*bit //'`
 
-# Check whether --with-libsigsegv-prefix was given.
-if test ${with_libsigsegv_prefix+y}
-then :
-  withval=$with_libsigsegv_prefix;
-    if test "X$withval" = "Xno"; then
-      use_additional=no
-    else
-      if test "X$withval" = "X"; then
+printf "%s\n" "#define DBL_SIGNBIT_WORD $word" >>confdefs.h
 
-  acl_save_prefix="$prefix"
-  prefix="$acl_final_prefix"
-  acl_save_exec_prefix="$exec_prefix"
-  exec_prefix="$acl_final_exec_prefix"
 
-          eval additional_includedir=\"$includedir\"
-          eval additional_libdir=\"$libdir\"
-          eval additional_libdir2=\"$exec_prefix/$acl_libdirstem2\"
-          eval additional_libdir3=\"$exec_prefix/$acl_libdirstem3\"
+printf "%s\n" "#define DBL_SIGNBIT_BIT $bit" >>confdefs.h
 
-  exec_prefix="$acl_save_exec_prefix"
-  prefix="$acl_save_prefix"
+      ;;
+  esac
 
-      else
-        additional_includedir="$withval/include"
-        additional_libdir="$withval/$acl_libdirstem"
-        additional_libdir2="$withval/$acl_libdirstem2"
-        additional_libdir3="$withval/$acl_libdirstem3"
-      fi
-    fi
 
-fi
 
-  if test "X$additional_libdir2" = "X$additional_libdir"; then
-    additional_libdir2=
-  fi
-  if test "X$additional_libdir3" = "X$additional_libdir"; then
-    additional_libdir3=
-  fi
-      LIBSIGSEGV=
-  LTLIBSIGSEGV=
-  INCSIGSEGV=
-  LIBSIGSEGV_PREFIX=
-      HAVE_LIBSIGSEGV=
-  rpathdirs=
-  ltrpathdirs=
-  names_already_handled=
-  names_next_round='sigsegv '
-  while test -n "$names_next_round"; do
-    names_this_round="$names_next_round"
-    names_next_round=
-    for name in $names_this_round; do
-      already_handled=
-      for n in $names_already_handled; do
-        if test "$n" = "$name"; then
-          already_handled=yes
-          break
-        fi
-      done
-      if test -z "$already_handled"; then
-        names_already_handled="$names_already_handled $name"
-                        uppername=`echo "$name" | sed -e 'y|abcdefghijklmnopqrstuvwxyz./+-|ABCDEFGHIJKLMNOPQRSTUVWXYZ____|'`
-        eval value=\"\$HAVE_LIB$uppername\"
-        if test -n "$value"; then
-          if test "$value" = yes; then
-            eval value=\"\$LIB$uppername\"
-            test -z "$value" || LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$value"
-            eval value=\"\$LTLIB$uppername\"
-            test -z "$value" || LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }$value"
-          else
-                                    :
-          fi
-        else
-                              found_dir=
-          found_la=
-          found_so=
-          found_a=
-          eval libname=\"$acl_libname_spec\"    # typically: libname=lib$name
-          if test -n "$acl_shlibext"; then
-            shrext=".$acl_shlibext"             # typically: shrext=.so
-          else
-            shrext=
-          fi
-          if test $use_additional = yes; then
-            for additional_libdir_variable in additional_libdir additional_libdir2 additional_libdir3; do
-              if test "X$found_dir" = "X"; then
-                eval dir=\$$additional_libdir_variable
-                if test -n "$dir"; then
-                                                      if test -n "$acl_shlibext"; then
-                    if test -f "$dir/$libname$shrext" && acl_is_expected_elfclass < "$dir/$libname$shrext"; then
-                      found_dir="$dir"
-                      found_so="$dir/$libname$shrext"
-                    else
-                      if test "$acl_library_names_spec" = '$libname$shrext$versuffix'; then
-                        ver=`(cd "$dir" && \
-                              for f in "$libname$shrext".*; do echo "$f"; done \
-                              | sed -e "s,^$libname$shrext\\\\.,," \
-                              | sort -t '.' -n -r -k1,1 -k2,2 -k3,3 -k4,4 -k5,5 \
-                              | sed 1q ) 2>/dev/null`
-                        if test -n "$ver" && test -f "$dir/$libname$shrext.$ver" && acl_is_expected_elfclass < "$dir/$libname$shrext.$ver"; then
-                          found_dir="$dir"
-                          found_so="$dir/$libname$shrext.$ver"
-                        fi
-                      else
-                        eval library_names=\"$acl_library_names_spec\"
-                        for f in $library_names; do
-                          if test -f "$dir/$f" && acl_is_expected_elfclass < "$dir/$f"; then
-                            found_dir="$dir"
-                            found_so="$dir/$f"
-                            break
-                          fi
-                        done
-                      fi
-                    fi
-                  fi
-                                    if test "X$found_dir" = "X"; then
-                    if test -f "$dir/$libname.$acl_libext" && ${AR-ar} -p "$dir/$libname.$acl_libext" | acl_is_expected_elfclass; then
-                      found_dir="$dir"
-                      found_a="$dir/$libname.$acl_libext"
-                    fi
-                  fi
-                  if test "X$found_dir" != "X"; then
-                    if test -f "$dir/$libname.la"; then
-                      found_la="$dir/$libname.la"
-                    fi
-                  fi
-                fi
-              fi
-            done
-          fi
-          if test "X$found_dir" = "X"; then
-            for x in $LDFLAGS $LTLIBSIGSEGV; do
 
-  acl_save_prefix="$prefix"
-  prefix="$acl_final_prefix"
-  acl_save_exec_prefix="$exec_prefix"
-  exec_prefix="$acl_final_exec_prefix"
-  eval x=\"$x\"
-  exec_prefix="$acl_save_exec_prefix"
-  prefix="$acl_save_prefix"
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking where to find the sign bit in a 'long double'" >&5
+printf %s "checking where to find the sign bit in a 'long double'... " >&6; }
+if test ${gl_cv_cc_long_double_signbit+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
-              case "$x" in
-                -L*)
-                  dir=`echo "X$x" | sed -e 's/^X-L//'`
-                                    if test -n "$acl_shlibext"; then
-                    if test -f "$dir/$libname$shrext" && acl_is_expected_elfclass < "$dir/$libname$shrext"; then
-                      found_dir="$dir"
-                      found_so="$dir/$libname$shrext"
-                    else
-                      if test "$acl_library_names_spec" = '$libname$shrext$versuffix'; then
-                        ver=`(cd "$dir" && \
-                              for f in "$libname$shrext".*; do echo "$f"; done \
-                              | sed -e "s,^$libname$shrext\\\\.,," \
-                              | sort -t '.' -n -r -k1,1 -k2,2 -k3,3 -k4,4 -k5,5 \
-                              | sed 1q ) 2>/dev/null`
-                        if test -n "$ver" && test -f "$dir/$libname$shrext.$ver" && acl_is_expected_elfclass < "$dir/$libname$shrext.$ver"; then
-                          found_dir="$dir"
-                          found_so="$dir/$libname$shrext.$ver"
-                        fi
-                      else
-                        eval library_names=\"$acl_library_names_spec\"
-                        for f in $library_names; do
-                          if test -f "$dir/$f" && acl_is_expected_elfclass < "$dir/$f"; then
-                            found_dir="$dir"
-                            found_so="$dir/$f"
-                            break
-                          fi
-                        done
-                      fi
-                    fi
-                  fi
-                                    if test "X$found_dir" = "X"; then
-                    if test -f "$dir/$libname.$acl_libext" && ${AR-ar} -p "$dir/$libname.$acl_libext" | acl_is_expected_elfclass; then
-                      found_dir="$dir"
-                      found_a="$dir/$libname.$acl_libext"
-                    fi
-                  fi
-                  if test "X$found_dir" != "X"; then
-                    if test -f "$dir/$libname.la"; then
-                      found_la="$dir/$libname.la"
-                    fi
-                  fi
-                  ;;
-              esac
-              if test "X$found_dir" != "X"; then
-                break
-              fi
-            done
-          fi
-          if test "X$found_dir" != "X"; then
-                        LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }-L$found_dir -l$name"
-            if test "X$found_so" != "X"; then
-                                                        if test "$enable_rpath" = no \
-                 || test "X$found_dir" = "X/usr/$acl_libdirstem" \
-                 || test "X$found_dir" = "X/usr/$acl_libdirstem2" \
-                 || test "X$found_dir" = "X/usr/$acl_libdirstem3"; then
-                                LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$found_so"
-              else
-                                                                                haveit=
-                for x in $ltrpathdirs; do
-                  if test "X$x" = "X$found_dir"; then
-                    haveit=yes
-                    break
-                  fi
-                done
-                if test -z "$haveit"; then
-                  ltrpathdirs="$ltrpathdirs $found_dir"
-                fi
-                                if test "$acl_hardcode_direct" = yes; then
-                                                      LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$found_so"
-                else
-                  if test -n "$acl_hardcode_libdir_flag_spec" && test "$acl_hardcode_minus_L" = no; then
-                                                            LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$found_so"
-                                                            haveit=
-                    for x in $rpathdirs; do
-                      if test "X$x" = "X$found_dir"; then
-                        haveit=yes
-                        break
-                      fi
-                    done
-                    if test -z "$haveit"; then
-                      rpathdirs="$rpathdirs $found_dir"
-                    fi
-                  else
-                                                                                haveit=
-                    for x in $LDFLAGS $LIBSIGSEGV; do
+      if test "$cross_compiling" = yes
+then :
 
-  acl_save_prefix="$prefix"
-  prefix="$acl_final_prefix"
-  acl_save_exec_prefix="$exec_prefix"
-  exec_prefix="$acl_final_exec_prefix"
-  eval x=\"$x\"
-  exec_prefix="$acl_save_exec_prefix"
-  prefix="$acl_save_prefix"
+                              gl_cv_cc_long_double_signbit="unknown"
 
-                      if test "X$x" = "X-L$found_dir"; then
-                        haveit=yes
-                        break
-                      fi
-                    done
-                    if test -z "$haveit"; then
-                      LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }-L$found_dir"
-                    fi
-                    if test "$acl_hardcode_minus_L" != no; then
-                                                                                        LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$found_so"
-                    else
-                                                                                                                                                                                LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }-l$name"
-                    fi
-                  fi
-                fi
-              fi
-            else
-              if test "X$found_a" != "X"; then
-                                LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$found_a"
-              else
-                                                LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }-L$found_dir -l$name"
-              fi
-            fi
-                        additional_includedir=
-            case "$found_dir" in
-              */$acl_libdirstem | */$acl_libdirstem/)
-                basedir=`echo "X$found_dir" | sed -e 's,^X,,' -e "s,/$acl_libdirstem/"'*$,,'`
-                if test "$name" = 'sigsegv'; then
-                  LIBSIGSEGV_PREFIX="$basedir"
-                fi
-                additional_includedir="$basedir/include"
-                ;;
-              */$acl_libdirstem2 | */$acl_libdirstem2/)
-                basedir=`echo "X$found_dir" | sed -e 's,^X,,' -e "s,/$acl_libdirstem2/"'*$,,'`
-                if test "$name" = 'sigsegv'; then
-                  LIBSIGSEGV_PREFIX="$basedir"
-                fi
-                additional_includedir="$basedir/include"
-                ;;
-              */$acl_libdirstem3 | */$acl_libdirstem3/)
-                basedir=`echo "X$found_dir" | sed -e 's,^X,,' -e "s,/$acl_libdirstem3/"'*$,,'`
-                if test "$name" = 'sigsegv'; then
-                  LIBSIGSEGV_PREFIX="$basedir"
-                fi
-                additional_includedir="$basedir/include"
-                ;;
-            esac
-            if test "X$additional_includedir" != "X"; then
-                                                                                                                if test "X$additional_includedir" != "X/usr/include"; then
-                haveit=
-                if test "X$additional_includedir" = "X/usr/local/include"; then
-                  if test -n "$GCC"; then
-                    case $host_os in
-                      linux* | gnu* | k*bsd*-gnu) haveit=yes;;
-                    esac
-                  fi
-                fi
-                if test -z "$haveit"; then
-                  for x in $CPPFLAGS $INCSIGSEGV; do
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
 
-  acl_save_prefix="$prefix"
-  prefix="$acl_final_prefix"
-  acl_save_exec_prefix="$exec_prefix"
-  exec_prefix="$acl_final_exec_prefix"
-  eval x=\"$x\"
-  exec_prefix="$acl_save_exec_prefix"
-  prefix="$acl_save_prefix"
+#include <stddef.h>
+#include <stdio.h>
+#define NWORDS \
+  ((sizeof (long double) + sizeof (unsigned int) - 1) / sizeof (unsigned int))
+typedef union { long double value; unsigned int word[NWORDS]; }
+        memory_float;
+static memory_float plus = { 1.0L };
+static memory_float minus = { -1.0L };
+int main ()
+{
+  size_t j, k, i;
+  unsigned int m;
+  FILE *fp = fopen ("conftest.out", "w");
+  if (fp == NULL)
+    return 1;
+  /* Find the different bit.  */
+  k = 0; m = 0;
+  for (j = 0; j < NWORDS; j++)
+    {
+      unsigned int x = plus.word[j] ^ minus.word[j];
+      if ((x & (x - 1)) || (x && m))
+        {
+          /* More than one bit difference.  */
+          fprintf (fp, "unknown");
+          fclose (fp);
+          return 2;
+        }
+      if (x)
+        {
+          k = j;
+          m = x;
+        }
+    }
+  if (m == 0)
+    {
+      /* No difference.  */
+      fprintf (fp, "unknown");
+      fclose (fp);
+      return 3;
+    }
+  /* Now m = plus.word[k] ^ ~minus.word[k].  */
+  if (plus.word[k] & ~minus.word[k])
+    {
+      /* Oh? The sign bit is set in the positive and cleared in the negative
+         numbers?  */
+      fprintf (fp, "unknown");
+      fclose (fp);
+      return 4;
+    }
+  for (i = 0; ; i++)
+    if ((m >> i) & 1)
+      break;
+  fprintf (fp, "word %d bit %d", (int) k, (int) i);
+  if (fclose (fp) != 0)
+    return 5;
+  return 0;
+}
 
-                    if test "X$x" = "X-I$additional_includedir"; then
-                      haveit=yes
-                      break
-                    fi
-                  done
-                  if test -z "$haveit"; then
-                    if test -d "$additional_includedir"; then
-                                            INCSIGSEGV="${INCSIGSEGV}${INCSIGSEGV:+ }-I$additional_includedir"
-                    fi
-                  fi
-                fi
-              fi
-            fi
-                        if test -n "$found_la"; then
-                                                        save_libdir="$libdir"
-              case "$found_la" in
-                */* | *\\*) . "$found_la" ;;
-                *) . "./$found_la" ;;
-              esac
-              libdir="$save_libdir"
-                            for dep in $dependency_libs; do
-                case "$dep" in
-                  -L*)
-                    dependency_libdir=`echo "X$dep" | sed -e 's/^X-L//'`
-                                                                                                                                                                if test "X$dependency_libdir" != "X/usr/$acl_libdirstem" \
-                       && test "X$dependency_libdir" != "X/usr/$acl_libdirstem2" \
-                       && test "X$dependency_libdir" != "X/usr/$acl_libdirstem3"; then
-                      haveit=
-                      if test "X$dependency_libdir" = "X/usr/local/$acl_libdirstem" \
-                         || test "X$dependency_libdir" = "X/usr/local/$acl_libdirstem2" \
-                         || test "X$dependency_libdir" = "X/usr/local/$acl_libdirstem3"; then
-                        if test -n "$GCC"; then
-                          case $host_os in
-                            linux* | gnu* | k*bsd*-gnu) haveit=yes;;
-                          esac
-                        fi
-                      fi
-                      if test -z "$haveit"; then
-                        haveit=
-                        for x in $LDFLAGS $LIBSIGSEGV; do
+_ACEOF
+if ac_fn_c_try_run "$LINENO"
+then :
+  gl_cv_cc_long_double_signbit=`cat conftest.out`
+else $as_nop
+  gl_cv_cc_long_double_signbit="unknown"
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
 
-  acl_save_prefix="$prefix"
-  prefix="$acl_final_prefix"
-  acl_save_exec_prefix="$exec_prefix"
-  exec_prefix="$acl_final_exec_prefix"
-  eval x=\"$x\"
-  exec_prefix="$acl_save_exec_prefix"
-  prefix="$acl_save_prefix"
+      rm -f conftest.out
 
-                          if test "X$x" = "X-L$dependency_libdir"; then
-                            haveit=yes
-                            break
-                          fi
-                        done
-                        if test -z "$haveit"; then
-                          if test -d "$dependency_libdir"; then
-                                                        LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }-L$dependency_libdir"
-                          fi
-                        fi
-                        haveit=
-                        for x in $LDFLAGS $LTLIBSIGSEGV; do
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_cc_long_double_signbit" >&5
+printf "%s\n" "$gl_cv_cc_long_double_signbit" >&6; }
+  case "$gl_cv_cc_long_double_signbit" in
+    word*bit*)
+      word=`echo "$gl_cv_cc_long_double_signbit" | sed -e 's/word //' -e 's/ bit.*//'`
+      bit=`echo "$gl_cv_cc_long_double_signbit" | sed -e 's/word.*bit //'`
 
-  acl_save_prefix="$prefix"
-  prefix="$acl_final_prefix"
-  acl_save_exec_prefix="$exec_prefix"
-  exec_prefix="$acl_final_exec_prefix"
-  eval x=\"$x\"
-  exec_prefix="$acl_save_exec_prefix"
-  prefix="$acl_save_prefix"
+printf "%s\n" "#define LDBL_SIGNBIT_WORD $word" >>confdefs.h
 
-                          if test "X$x" = "X-L$dependency_libdir"; then
-                            haveit=yes
-                            break
-                          fi
-                        done
-                        if test -z "$haveit"; then
-                          if test -d "$dependency_libdir"; then
-                                                        LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }-L$dependency_libdir"
-                          fi
-                        fi
-                      fi
-                    fi
-                    ;;
-                  -R*)
-                    dir=`echo "X$dep" | sed -e 's/^X-R//'`
-                    if test "$enable_rpath" != no; then
-                                                                  haveit=
-                      for x in $rpathdirs; do
-                        if test "X$x" = "X$dir"; then
-                          haveit=yes
-                          break
-                        fi
-                      done
-                      if test -z "$haveit"; then
-                        rpathdirs="$rpathdirs $dir"
-                      fi
-                                                                  haveit=
-                      for x in $ltrpathdirs; do
-                        if test "X$x" = "X$dir"; then
-                          haveit=yes
-                          break
-                        fi
-                      done
-                      if test -z "$haveit"; then
-                        ltrpathdirs="$ltrpathdirs $dir"
-                      fi
-                    fi
-                    ;;
-                  -l*)
-                                                                                                                                                                dep=`echo "X$dep" | sed -e 's/^X-l//'`
-                    if test "X$dep" != Xc \
-                       || case $host_os in
-                            linux* | gnu* | k*bsd*-gnu) false ;;
-                            *)                          true ;;
-                          esac; then
-                      names_next_round="$names_next_round $dep"
-                    fi
-                    ;;
-                  *.la)
-                                                                                names_next_round="$names_next_round "`echo "X$dep" | sed -e 's,^X.*/,,' -e 's,^lib,,' -e 's,\.la$,,'`
-                    ;;
-                  *)
-                                        LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$dep"
-                    LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }$dep"
-                    ;;
-                esac
-              done
-            fi
-          else
-                                                            LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }-l$name"
-            LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }-l$name"
-          fi
-        fi
-      fi
-    done
-  done
-  if test "X$rpathdirs" != "X"; then
-    if test -n "$acl_hardcode_libdir_separator"; then
-                        alldirs=
-      for found_dir in $rpathdirs; do
-        alldirs="${alldirs}${alldirs:+$acl_hardcode_libdir_separator}$found_dir"
-      done
-            acl_save_libdir="$libdir"
-      libdir="$alldirs"
-      eval flag=\"$acl_hardcode_libdir_flag_spec\"
-      libdir="$acl_save_libdir"
-      LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$flag"
-    else
-            for found_dir in $rpathdirs; do
-        acl_save_libdir="$libdir"
-        libdir="$found_dir"
-        eval flag=\"$acl_hardcode_libdir_flag_spec\"
-        libdir="$acl_save_libdir"
-        LIBSIGSEGV="${LIBSIGSEGV}${LIBSIGSEGV:+ }$flag"
-      done
-    fi
-  fi
-  if test "X$ltrpathdirs" != "X"; then
-            for found_dir in $ltrpathdirs; do
-      LTLIBSIGSEGV="${LTLIBSIGSEGV}${LTLIBSIGSEGV:+ }-R$found_dir"
-    done
-  fi
 
+printf "%s\n" "#define LDBL_SIGNBIT_BIT $bit" >>confdefs.h
 
+      ;;
+  esac
 
 
+    if test "$gl_cv_cc_float_signbit" = unknown; then
+            ac_fn_check_decl "$LINENO" "copysignf" "ac_cv_have_decl_copysignf" "#include <math.h>
+" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_copysignf" = xyes
+then :
+  ac_have_decl=1
+else $as_nop
+  ac_have_decl=0
+fi
+printf "%s\n" "#define HAVE_DECL_COPYSIGNF $ac_have_decl" >>confdefs.h
 
+      if test "$ac_cv_have_decl_copysignf" = yes; then
+                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether copysignf can be used without linking with libm" >&5
+printf %s "checking whether copysignf can be used without linking with libm... " >&6; }
+if test ${gl_cv_func_copysignf_no_libm+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
-        ac_save_CPPFLAGS="$CPPFLAGS"
+            cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <math.h>
+                   float x, y;
+int
+main (void)
+{
+return copysignf (x, y) < 0;
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"
+then :
+  gl_cv_func_copysignf_no_libm=yes
+else $as_nop
+  gl_cv_func_copysignf_no_libm=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
 
-  for element in $INCSIGSEGV; do
-    haveit=
-    for x in $CPPFLAGS; do
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_copysignf_no_libm" >&5
+printf "%s\n" "$gl_cv_func_copysignf_no_libm" >&6; }
+        if test $gl_cv_func_copysignf_no_libm = yes; then
 
-  acl_save_prefix="$prefix"
-  prefix="$acl_final_prefix"
-  acl_save_exec_prefix="$exec_prefix"
-  exec_prefix="$acl_final_exec_prefix"
-  eval x=\"$x\"
-  exec_prefix="$acl_save_exec_prefix"
-  prefix="$acl_save_prefix"
+printf "%s\n" "#define HAVE_COPYSIGNF_IN_LIBC 1" >>confdefs.h
 
-      if test "X$x" = "X$element"; then
-        haveit=yes
-        break
+        fi
       fi
-    done
-    if test -z "$haveit"; then
-      CPPFLAGS="${CPPFLAGS}${CPPFLAGS:+ }$element"
     fi
-  done
+    if test "$gl_cv_cc_double_signbit" = unknown; then
+            ac_fn_check_decl "$LINENO" "copysign" "ac_cv_have_decl_copysign" "#include <math.h>
+" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_copysign" = xyes
+then :
+  ac_have_decl=1
+else $as_nop
+  ac_have_decl=0
+fi
+printf "%s\n" "#define HAVE_DECL_COPYSIGN $ac_have_decl" >>confdefs.h
 
+      if test "$ac_cv_have_decl_copysign" = yes; then
+                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether copysign can be used without linking with libm" >&5
+printf %s "checking whether copysign can be used without linking with libm... " >&6; }
+if test ${gl_cv_func_copysign_no_libm+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
 
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libsigsegv" >&5
-printf %s "checking for libsigsegv... " >&6; }
-if test ${ac_cv_libsigsegv+y}
+            cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <math.h>
+                   double x, y;
+int
+main (void)
+{
+return copysign (x, y) < 0;
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"
+then :
+  gl_cv_func_copysign_no_libm=yes
+else $as_nop
+  gl_cv_func_copysign_no_libm=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_copysign_no_libm" >&5
+printf "%s\n" "$gl_cv_func_copysign_no_libm" >&6; }
+        if test $gl_cv_func_copysign_no_libm = yes; then
+
+printf "%s\n" "#define HAVE_COPYSIGN_IN_LIBC 1" >>confdefs.h
+
+        fi
+      fi
+    fi
+    if test "$gl_cv_cc_long_double_signbit" = unknown; then
+            ac_fn_check_decl "$LINENO" "copysignl" "ac_cv_have_decl_copysignl" "#include <math.h>
+" "$ac_c_undeclared_builtin_options" "CFLAGS"
+if test "x$ac_cv_have_decl_copysignl" = xyes
+then :
+  ac_have_decl=1
+else $as_nop
+  ac_have_decl=0
+fi
+printf "%s\n" "#define HAVE_DECL_COPYSIGNL $ac_have_decl" >>confdefs.h
+
+      if test "$ac_cv_have_decl_copysignl" = yes; then
+                { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether copysignl can be used without linking with libm" >&5
+printf %s "checking whether copysignl can be used without linking with libm... " >&6; }
+if test ${gl_cv_func_copysignl_no_libm+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
 
-    ac_save_LIBS="$LIBS"
-                                case " $LIBSIGSEGV" in
-      *" -l"*) LIBS="$LIBS $LIBSIGSEGV" ;;
-      *)       LIBS="$LIBSIGSEGV $LIBS" ;;
-    esac
-    cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+            cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-#include <sigsegv.h>
+#include <math.h>
+                   long double x, y;
 int
 main (void)
 {
-sigsegv_deinstall_handler();
+return copysignl (x, y) < 0;
   ;
   return 0;
 }
 _ACEOF
 if ac_fn_c_try_link "$LINENO"
 then :
-  ac_cv_libsigsegv=yes
+  gl_cv_func_copysignl_no_libm=yes
 else $as_nop
-  ac_cv_libsigsegv='no, consider installing GNU libsigsegv'
+  gl_cv_func_copysignl_no_libm=no
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam \
     conftest$ac_exeext conftest.$ac_ext
-    LIBS="$ac_save_LIBS"
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_libsigsegv" >&5
-printf "%s\n" "$ac_cv_libsigsegv" >&6; }
-  if test "$ac_cv_libsigsegv" = yes; then
-    HAVE_LIBSIGSEGV=yes
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $gl_cv_func_copysignl_no_libm" >&5
+printf "%s\n" "$gl_cv_func_copysignl_no_libm" >&6; }
+        if test $gl_cv_func_copysignl_no_libm = yes; then
 
-printf "%s\n" "#define HAVE_LIBSIGSEGV 1" >>confdefs.h
+printf "%s\n" "#define HAVE_COPYSIGNL_IN_LIBC 1" >>confdefs.h
+
+        fi
+      fi
+    fi
+  fi
+
+  if test $REPLACE_SIGNBIT = 1; then
+
+
+
+
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS signbitf.$ac_objext"
+
+
+
+
+
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS signbitd.$ac_objext"
+
+
+
+
+
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS signbitl.$ac_objext"
 
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking how to link with libsigsegv" >&5
-printf %s "checking how to link with libsigsegv... " >&6; }
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LIBSIGSEGV" >&5
-printf "%s\n" "$LIBSIGSEGV" >&6; }
-  else
-    HAVE_LIBSIGSEGV=no
-            CPPFLAGS="$ac_save_CPPFLAGS"
-    LIBSIGSEGV=
-    LTLIBSIGSEGV=
-    LIBSIGSEGV_PREFIX=
   fi
 
 
@@ -46346,11 +46276,104 @@
 
 
 
-    gl_cv_lib_sigsegv="$ac_cv_libsigsegv"
 
-    if test "$gl_cv_lib_sigsegv" = yes; then
-      SIGSEGV_H=
-    fi
+
+          GL_M4_GNULIB_SIGNBIT=1
+
+
+
+
+
+printf "%s\n" "#define GNULIB_TEST_SIGNBIT 1" >>confdefs.h
+
+
+
+
+
+
+
+
+printf "%s\n" "#define GNULIB_SIGPIPE 1" >>confdefs.h
+
+
+
+
+
+
+
+
+  GL_M4_GNULIB_SIGNAL_H_SIGPIPE=1
+
+
+
+
+
+
+
+
+
+  GL_M4_GNULIB_STDIO_H_SIGPIPE=1
+
+
+
+
+
+
+
+
+  GL_M4_GNULIB_UNISTD_H_SIGPIPE=1
+
+
+
+
+
+  HAVE_POSIX_SIGNALBLOCKING=0
+  if test "$gl_cv_type_sigset_t" = yes; then
+    ac_fn_c_check_func "$LINENO" "sigprocmask" "ac_cv_func_sigprocmask"
+if test "x$ac_cv_func_sigprocmask" = xyes
+then :
+  HAVE_POSIX_SIGNALBLOCKING=1
+fi
+
+  fi
+
+  if test $HAVE_POSIX_SIGNALBLOCKING = 0; then
+
+
+
+
+
+
+
+
+  M4_LIBOBJS="$M4_LIBOBJS sigprocmask.$ac_objext"
+
+    :
+  fi
+
+
+
+
+
+
+
+
+
+          GL_M4_GNULIB_SIGPROCMASK=1
+
+
+
+
+
+printf "%s\n" "#define GNULIB_TEST_SIGPROCMASK 1" >>confdefs.h
+
+
+
+
+  if test $gl_sigsegv_uses_libsigsegv = yes; then
+    SIGSEGV_H=
+  else
+    SIGSEGV_H=sigsegv.h
   fi
 
    if test -n "$SIGSEGV_H"; then
--- lib/Makefile.in	2025-03-29 15:48:38.000000000 +0000
+++ lib/Makefile.in	2025-03-29 16:14:09.000000000 +0000
@@ -315,12 +315,13 @@
 	$(top_srcdir)/m4/sig_atomic_t.m4 $(top_srcdir)/m4/sigaction.m4 \
 	$(top_srcdir)/m4/sigaltstack.m4 $(top_srcdir)/m4/signal_h.m4 \
 	$(top_srcdir)/m4/signalblocking.m4 $(top_srcdir)/m4/signbit.m4 \
-	$(top_srcdir)/m4/sigpipe.m4 $(top_srcdir)/m4/size_max.m4 \
-	$(top_srcdir)/m4/sleep.m4 $(top_srcdir)/m4/snprintf.m4 \
-	$(top_srcdir)/m4/socketlib.m4 $(top_srcdir)/m4/sockets.m4 \
-	$(top_srcdir)/m4/socklen.m4 $(top_srcdir)/m4/sockpfaf.m4 \
-	$(top_srcdir)/m4/sparcv8+.m4 $(top_srcdir)/m4/spawn-pipe.m4 \
-	$(top_srcdir)/m4/spawn_h.m4 $(top_srcdir)/m4/ssize_t.m4 \
+	$(top_srcdir)/m4/sigpipe.m4 $(top_srcdir)/m4/sigsegv.m4 \
+	$(top_srcdir)/m4/size_max.m4 $(top_srcdir)/m4/sleep.m4 \
+	$(top_srcdir)/m4/snprintf.m4 $(top_srcdir)/m4/socketlib.m4 \
+	$(top_srcdir)/m4/sockets.m4 $(top_srcdir)/m4/socklen.m4 \
+	$(top_srcdir)/m4/sockpfaf.m4 $(top_srcdir)/m4/sparcv8+.m4 \
+	$(top_srcdir)/m4/spawn-pipe.m4 $(top_srcdir)/m4/spawn_h.m4 \
+	$(top_srcdir)/m4/ssize_t.m4 \
 	$(top_srcdir)/m4/stack-direction.m4 \
 	$(top_srcdir)/m4/stat-time.m4 $(top_srcdir)/m4/stat.m4 \
 	$(top_srcdir)/m4/stdalign.m4 $(top_srcdir)/m4/stdarg.m4 \
--- m4/c-stack.m4	2025-03-29 15:48:39.000000000 +0000
+++ m4/c-stack.m4	2025-03-29 15:49:47.000000000 +0000
@@ -12,10 +12,9 @@
 AC_DEFUN([gl_C_STACK],
 [
   dnl 'c-stack' needs -lsigsegv if and only if the 'sigsegv' module needs it.
-  if test "$with_libsigsegv" = yes; then
-    if test "$gl_cv_lib_sigsegv" = yes; then
-      AC_SUBST([LIBCSTACK], [$LIBSIGSEGV])
-      AC_SUBST([LTLIBCSTACK], [$LTLIBSIGSEGV])
-    fi
+  AC_REQUIRE([gl_SIGSEGV])
+  if test $gl_sigsegv_uses_libsigsegv = yes; then
+    AC_SUBST([LIBCSTACK], [$LIBSIGSEGV])
+    AC_SUBST([LTLIBCSTACK], [$LTLIBSIGSEGV])
   fi
 ])
--- m4/gnulib-comp.m4	2025-03-29 15:48:39.000000000 +0000
+++ m4/gnulib-comp.m4	2025-03-29 15:51:33.000000000 +0000
@@ -1394,15 +1394,11 @@
     gl_PREREQ_SIGPROCMASK
   fi
   gl_SIGNAL_MODULE_INDICATOR([sigprocmask])
-  AC_ARG_WITH([libsigsegv],
-    [AS_HELP_STRING([--with-libsigsegv],
-       [use the GNU libsigsegv library, when present, instead of the gnulib module 'sigsegv'])])
-  SIGSEGV_H=sigsegv.h
-  if test "$with_libsigsegv" = yes; then
-    gl_LIBSIGSEGV
-    if test "$gl_cv_lib_sigsegv" = yes; then
-      SIGSEGV_H=
-    fi
+  AC_REQUIRE([gl_SIGSEGV])
+  if test $gl_sigsegv_uses_libsigsegv = yes; then
+    SIGSEGV_H=
+  else
+    SIGSEGV_H=sigsegv.h
   fi
   AC_SUBST([SIGSEGV_H])
   AM_CONDITIONAL([GL_GENERATE_SIGSEGV_H], [test -n "$SIGSEGV_H"])
--- m4/sigsegv.m4	1970-01-01 01:00:00.000000000 +0100
+++ m4/sigsegv.m4	2025-03-29 15:50:19.000000000 +0000
@@ -0,0 +1,22 @@
+# sigsegv.m4
+# serial 2
+dnl Copyright (C) 2021-2025 Free Software Foundation, Inc.
+dnl This file is free software; the Free Software Foundation
+dnl gives unlimited permission to copy and/or distribute it,
+dnl with or without modifications, as long as this notice is preserved.
+dnl This file is offered as-is, without any warranty.
+
+dnl From Bruno Haible.
+
+AC_DEFUN_ONCE([gl_SIGSEGV],
+[
+  AC_ARG_WITH([libsigsegv],
+    [AS_HELP_STRING([[--with-libsigsegv]],
+       [use the GNU libsigsegv library, when present, instead of the gnulib module 'sigsegv'])])
+  if test "$with_libsigsegv" = yes; then
+    gl_LIBSIGSEGV
+    gl_sigsegv_uses_libsigsegv="$gl_cv_lib_sigsegv"
+  else
+    gl_sigsegv_uses_libsigsegv=no
+  fi
+])
--- src/Makefile.in	2025-03-29 15:48:39.000000000 +0000
+++ src/Makefile.in	2025-03-29 16:14:09.000000000 +0000
@@ -208,12 +208,13 @@
 	$(top_srcdir)/m4/sig_atomic_t.m4 $(top_srcdir)/m4/sigaction.m4 \
 	$(top_srcdir)/m4/sigaltstack.m4 $(top_srcdir)/m4/signal_h.m4 \
 	$(top_srcdir)/m4/signalblocking.m4 $(top_srcdir)/m4/signbit.m4 \
-	$(top_srcdir)/m4/sigpipe.m4 $(top_srcdir)/m4/size_max.m4 \
-	$(top_srcdir)/m4/sleep.m4 $(top_srcdir)/m4/snprintf.m4 \
-	$(top_srcdir)/m4/socketlib.m4 $(top_srcdir)/m4/sockets.m4 \
-	$(top_srcdir)/m4/socklen.m4 $(top_srcdir)/m4/sockpfaf.m4 \
-	$(top_srcdir)/m4/sparcv8+.m4 $(top_srcdir)/m4/spawn-pipe.m4 \
-	$(top_srcdir)/m4/spawn_h.m4 $(top_srcdir)/m4/ssize_t.m4 \
+	$(top_srcdir)/m4/sigpipe.m4 $(top_srcdir)/m4/sigsegv.m4 \
+	$(top_srcdir)/m4/size_max.m4 $(top_srcdir)/m4/sleep.m4 \
+	$(top_srcdir)/m4/snprintf.m4 $(top_srcdir)/m4/socketlib.m4 \
+	$(top_srcdir)/m4/sockets.m4 $(top_srcdir)/m4/socklen.m4 \
+	$(top_srcdir)/m4/sockpfaf.m4 $(top_srcdir)/m4/sparcv8+.m4 \
+	$(top_srcdir)/m4/spawn-pipe.m4 $(top_srcdir)/m4/spawn_h.m4 \
+	$(top_srcdir)/m4/ssize_t.m4 \
 	$(top_srcdir)/m4/stack-direction.m4 \
 	$(top_srcdir)/m4/stat-time.m4 $(top_srcdir)/m4/stat.m4 \
 	$(top_srcdir)/m4/stdalign.m4 $(top_srcdir)/m4/stdarg.m4 \
--- Makefile.in	2025-03-29 15:48:39.000000000 +0000
+++ Makefile.in	2025-03-29 16:14:07.000000000 +0000
@@ -205,12 +205,13 @@
 	$(top_srcdir)/m4/sig_atomic_t.m4 $(top_srcdir)/m4/sigaction.m4 \
 	$(top_srcdir)/m4/sigaltstack.m4 $(top_srcdir)/m4/signal_h.m4 \
 	$(top_srcdir)/m4/signalblocking.m4 $(top_srcdir)/m4/signbit.m4 \
-	$(top_srcdir)/m4/sigpipe.m4 $(top_srcdir)/m4/size_max.m4 \
-	$(top_srcdir)/m4/sleep.m4 $(top_srcdir)/m4/snprintf.m4 \
-	$(top_srcdir)/m4/socketlib.m4 $(top_srcdir)/m4/sockets.m4 \
-	$(top_srcdir)/m4/socklen.m4 $(top_srcdir)/m4/sockpfaf.m4 \
-	$(top_srcdir)/m4/sparcv8+.m4 $(top_srcdir)/m4/spawn-pipe.m4 \
-	$(top_srcdir)/m4/spawn_h.m4 $(top_srcdir)/m4/ssize_t.m4 \
+	$(top_srcdir)/m4/sigpipe.m4 $(top_srcdir)/m4/sigsegv.m4 \
+	$(top_srcdir)/m4/size_max.m4 $(top_srcdir)/m4/sleep.m4 \
+	$(top_srcdir)/m4/snprintf.m4 $(top_srcdir)/m4/socketlib.m4 \
+	$(top_srcdir)/m4/sockets.m4 $(top_srcdir)/m4/socklen.m4 \
+	$(top_srcdir)/m4/sockpfaf.m4 $(top_srcdir)/m4/sparcv8+.m4 \
+	$(top_srcdir)/m4/spawn-pipe.m4 $(top_srcdir)/m4/spawn_h.m4 \
+	$(top_srcdir)/m4/ssize_t.m4 \
 	$(top_srcdir)/m4/stack-direction.m4 \
 	$(top_srcdir)/m4/stat-time.m4 $(top_srcdir)/m4/stat.m4 \
 	$(top_srcdir)/m4/stdalign.m4 $(top_srcdir)/m4/stdarg.m4 \
@@ -1952,7 +1953,7 @@
 top_build_prefix = @top_build_prefix@
 top_builddir = @top_builddir@
 top_srcdir = @top_srcdir@
-SUBDIRS = . examples lib src doc checks po tests
+SUBDIRS = . examples lib src doc checks po
 EXTRA_DIST = bootstrap c-boxes.el cfg.mk maint.mk \
 	.prev-version .version m4/gnulib-cache.m4 ChangeLog-2014
 

--- checks/Makefile.in	2025-03-29 15:48:39.000000000 +0000
+++ checks/Makefile.in	2025-03-29 16:14:07.000000000 +0000
@@ -205,12 +205,13 @@
 	$(top_srcdir)/m4/sig_atomic_t.m4 $(top_srcdir)/m4/sigaction.m4 \
 	$(top_srcdir)/m4/sigaltstack.m4 $(top_srcdir)/m4/signal_h.m4 \
 	$(top_srcdir)/m4/signalblocking.m4 $(top_srcdir)/m4/signbit.m4 \
-	$(top_srcdir)/m4/sigpipe.m4 $(top_srcdir)/m4/size_max.m4 \
-	$(top_srcdir)/m4/sleep.m4 $(top_srcdir)/m4/snprintf.m4 \
-	$(top_srcdir)/m4/socketlib.m4 $(top_srcdir)/m4/sockets.m4 \
-	$(top_srcdir)/m4/socklen.m4 $(top_srcdir)/m4/sockpfaf.m4 \
-	$(top_srcdir)/m4/sparcv8+.m4 $(top_srcdir)/m4/spawn-pipe.m4 \
-	$(top_srcdir)/m4/spawn_h.m4 $(top_srcdir)/m4/ssize_t.m4 \
+	$(top_srcdir)/m4/sigpipe.m4 $(top_srcdir)/m4/sigsegv.m4 \
+	$(top_srcdir)/m4/size_max.m4 $(top_srcdir)/m4/sleep.m4 \
+	$(top_srcdir)/m4/snprintf.m4 $(top_srcdir)/m4/socketlib.m4 \
+	$(top_srcdir)/m4/sockets.m4 $(top_srcdir)/m4/socklen.m4 \
+	$(top_srcdir)/m4/sockpfaf.m4 $(top_srcdir)/m4/sparcv8+.m4 \
+	$(top_srcdir)/m4/spawn-pipe.m4 $(top_srcdir)/m4/spawn_h.m4 \
+	$(top_srcdir)/m4/ssize_t.m4 \
 	$(top_srcdir)/m4/stack-direction.m4 \
 	$(top_srcdir)/m4/stat-time.m4 $(top_srcdir)/m4/stat.m4 \
 	$(top_srcdir)/m4/stdalign.m4 $(top_srcdir)/m4/stdarg.m4 \

--- checks/198.sysval	2025-03-29 15:48:38.000000000 +0000
+++ checks/198.sysval	2025-03-29 14:05:13.000000000 +0000
@@ -1,4 +1,4 @@
-dnl @ ../doc/m4.texi:6751: Origin of test
+dnl @ ../doc/m4.texi:6715: Origin of test
 dnl @ expected status: 0
 dnl @ extra options: 
 dnl @ Copyright (C) 2006, 2007, 2008, 2009 Free Software
@@ -7,26 +7,29 @@
 dnl @ gives unlimited permission to copy and/or distribute it
 dnl @ with or without modifications, as long as this notice
 dnl @ is preserved.
-dnl This test assumes kill is a shell builtin, and that signals are
-dnl recognizable.
-ifdef(`__unix__', ,
-      `errprint(` skipping: syscmd does not have unix semantics
-')m4exit(`77')')dnl
-changequote(`[', `]')
-dnl @result{}
-syscmd([/bin/sh -c 'kill -9 $$'; st=$?; test $st = 137 || test $st = 265])
-dnl @result{}
-ifelse(sysval, [0], , [errprint([ skipping: shell does not send signal 9
-])m4exit([77])])dnl
-syscmd([kill -9 $$])
+sysval
+dnl @result{}0
+syscmd(`false')
+dnl @result{}
+ifelse(sysval, `0', `zero', `non-zero')
+dnl @result{}non-zero
+syscmd(`exit 2')
 dnl @result{}
 sysval
-dnl @result{}2304
-syscmd()
+dnl @result{}2
+syscmd(`true')
 dnl @result{}
 sysval
 dnl @result{}0
-esyscmd([kill -9 $$])
+esyscmd(`false')
+dnl @result{}
+ifelse(sysval, `0', `zero', `non-zero')
+dnl @result{}non-zero
+esyscmd(`echo dnl && exit 127')
 dnl @result{}
 sysval
-dnl @result{}2304
+dnl @result{}127
+esyscmd(`true')
+dnl @result{}
+sysval
+dnl @result{}0

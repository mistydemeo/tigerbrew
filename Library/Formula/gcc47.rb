class Gcc47 < Formula
  desc "GNU compiler collection"
  def arch
    if Hardware::CPU.type == :intel
      if MacOS.prefer_64_bit?
        "x86_64"
      else
        "i686"
      end
    elsif Hardware::CPU.type == :ppc
      if MacOS.prefer_64_bit?
        "powerpc64"
      else
        "powerpc"
      end
    end
  end

  def osmajor
    `uname -r`.chomp
  end

  homepage "https://gcc.gnu.org"
  url "https://ftpmirror.gnu.org/gcc/gcc-4.7.4/gcc-4.7.4.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/gcc/gcc-4.7.4/gcc-4.7.4.tar.bz2"
  sha256 "92e61c6dc3a0a449e62d72a38185fda550168a86702dea07125ebd3ec3996282"
  revision 1

  head "svn://gcc.gnu.org/svn/gcc/branches/gcc-4_7-branch"

  bottle do
  end

  # Fixes build with Xcode 7.
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66523
  patch do
    url "https://gcc.gnu.org/bugzilla/attachment.cgi?id=35773"
    sha256 "db4966ade190fff4ed39976be8d13e84839098711713eff1d08920d37a58f5ec"
  end

  option "with-fortran", "Build the gfortran compiler"
  option "with-java", "Build the gcj compiler"
  option "with-all-languages", "Enable all compilers and languages, except Ada"
  option "with-nls", "Build with native language support (localization)"
  option "with-profiled-build", "Make use of profile guided optimization when bootstrapping GCC"
  # enabling multilib on a host that can't run 64-bit results in build failures
  option "without-multilib", "Build without multilib support" if MacOS.prefer_64_bit?

  deprecated_option "enable-fortran" => "with-fortran"
  deprecated_option "enable-java" => "with-java"
  deprecated_option "enable-all-languages" => "with-all-languages"
  deprecated_option "enable-nls" => "with-nls"
  deprecated_option "enable-profiled-build" => "with-profiled-build"
  deprecated_option "disable-multilib" => "without-multilib"

  depends_on "gmp4"
  depends_on "libmpc08"
  depends_on "mpfr2"
  depends_on "ppl011"
  depends_on "cloog-ppl015"
  depends_on "ecj" if build.with?("java") || build.with?("all-languages")

  # The as that comes with Tiger isn't capable of dealing with the
  # PPC asm that comes in libitm
  depends_on "cctools" => :build if MacOS.version < :leopard

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  def pour_bottle?
    MacOS::CLT.installed?
  end

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  # Fix 10.10 issues: https://gcc.gnu.org/viewcvs/gcc?view=revision&revision=215251
  patch :DATA

  def install
    # GCC Bug 25127 for PowerPC
    # https://gcc.gnu.org/bugzilla//show_bug.cgi?id=25127
    # ../../../libgcc/unwind.inc: In function '_Unwind_RaiseException':
    # ../../../libgcc/unwind.inc:136:1: internal compiler error: in rs6000_emit_prologue, at config/rs6000/rs6000.c:19445
    # "internal compiler error: Bus error" on Leopard
    ENV.no_optimization
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    # Otherwise libstdc++ will be incorrectly tagged with cpusubtype 10 (G4e)
    # https://github.com/mistydemeo/tigerbrew/issues/538
    ENV.append_to_cflags "-force_cpusubtype_ALL" if Hardware::CPU.family == :g3

    if build.with? "all-languages"
      # Everything but Ada, which requires a pre-existing GCC Ada compiler
      # (gnat) to bootstrap. GCC 4.6.0 add go as a language option, but it is
      # currently only compilable on Linux.
      languages = %w[c c++ fortran java objc obj-c++]
    else
      # C, C++, ObjC compilers are always built
      languages = %w[c c++ objc obj-c++]

      languages << "fortran" if build.with? "fortran"
      languages << "java" if build.with? "java"
    end

    version_suffix = version.to_s.slice(/\d\.\d/)

    args = [
      "--build=#{arch}-apple-darwin#{osmajor}",
      "--prefix=#{prefix}",
      "--enable-languages=#{languages.join(",")}",
      # Make most executables versioned to avoid conflicts.
      "--program-suffix=-#{version_suffix}",
      "--with-gmp=#{Formula["gmp4"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr2"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc08"].opt_prefix}",
      "--with-ppl=#{Formula["ppl011"].opt_prefix}",
      "--with-cloog=#{Formula["cloog-ppl015"].opt_prefix}",
      "--with-system-zlib",
      # This ensures lib, libexec, include are sandboxed so that they
      # don't wander around telling little children there is no Santa
      # Claus.
      "--enable-version-specific-runtime-libs",
      "--with-pkgversion=Tigerbrew #{name} #{pkg_version} #{build.used_options*" "}".strip,
      "--with-bugurl=https://github.com/mistydemeo/tigerbrew/issues",
    ]

    # "Building GCC with plugin support requires a host that supports
    # -fPIC, -shared, -ldl and -rdynamic."
    args << "--enable-plugin" if MacOS.version > :tiger

    # Otherwise make fails during comparison at stage 3
    # See: http://gcc.gnu.org/bugzilla/show_bug.cgi?id=45248
    args << "--with-dwarf2" if MacOS.version < :leopard

    args << "--disable-nls" if build.without? "nls"

    if build.with?("java") || build.with?("all-languages")
      args << "--with-ecj-jar=#{Formula["ecj"].opt_prefix}/share/java/ecj.jar"
    end

    if !MacOS.prefer_64_bit? || build.without?("multilib")
      args << "--disable-multilib"
    else
      args << "--enable-multilib"
    end

    mkdir "build" do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # "native-system-headers" will be appended
        args << "--with-native-system-header-dir=/usr/include"
        args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system "../configure", *args

      if build.with? "profiled-build"
        # Takes longer to build, may bug out. Provided for those who want to
        # optimise all the way to 11.
        system "make", "profiledbootstrap"
      else
        system "make", "bootstrap"
      end

      # At this point `make check` could be invoked to run the testsuite. The
      # deja-gnu and autogen formulae must be installed in order to do this.
      system "make", "install"
    end

    # Handle conflicts between GCC formulae.
    # Remove libffi stuff, which is not needed after GCC is built.
    Dir.glob(prefix/"**/libffi.*") { |file| File.delete file }
    # Rename libiberty.a.
    Dir.glob(prefix/"**/libiberty.*") { |file| add_suffix file, version_suffix }
    # Rename man7.
    Dir.glob(man7/"*.7") { |file| add_suffix file, version_suffix }

    # Even when suffixes are appended, the info pages conflict when
    # install-info is run. Fix this.
    info.rmtree

    # Rename java properties
    if build.with?("java") || build.with?("all-languages")
      config_files = [
        "#{lib}/logging.properties",
        "#{lib}/security/classpath.security",
        "#{lib}/i386/logging.properties",
        "#{lib}/i386/security/classpath.security",
      ]

      config_files.each do |file|
        add_suffix file, version_suffix if File.exist? file
      end
    end
  end

  def add_suffix(file, suffix)
    dir = File.dirname(file)
    ext = File.extname(file)
    base = File.basename(file, ext)
    File.rename file, "#{dir}/#{base}-#{suffix}#{ext}"
  end

  test do
    (testpath/"hello-c.c").write <<-EOS.undent
      #include <stdio.h>
      int main()
      {
        puts("Hello, world!");
        return 0;
      }
    EOS
    system bin/"gcc-4.7", "-o", "hello-c", "hello-c.c"
    assert_equal "Hello, world!\n", `./hello-c`

    (testpath/"hello-cc.cc").write <<-EOS.undent
      #include <iostream>
      int main()
      {
        std::cout << "Hello, world!" << std::endl;
        return 0;
      }
    EOS
    system "#{bin}/g++-4.7", "-o", "hello-cc", "hello-cc.cc"
    assert_equal "Hello, world!\n", `./hello-cc`

    (testpath/"test.f90").write <<-EOS.undent
      integer,parameter::m=10000
      real::a(m), b(m)
      real::fact=0.5

      do concurrent (i=1:m)
        a(i) = a(i) + fact*b(i)
      end do
      write(*,"(A)") "Done"
      end
    EOS
    system "#{bin}/gfortran-4.7", "-o", "test", "test.f90" if build.with? "fortran"
    assert_equal "Done\n", `./test` if build.with? "fortran"
  end
end
__END__
--- a/gcc/config/darwin-c.c
+++ b/gcc/config/darwin-c.c
@@ -571,21 +571,34 @@ find_subframework_header (cpp_reader *pfile, const char *header, cpp_dir **dirp)
 }
 
 /* Return the value of darwin_macosx_version_min suitable for the
-   __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ macro,
-   so '10.4.2' becomes 1040.  The lowest digit is always zero.
+   __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ macro, so '10.4.2'
+   becomes 1040 and '10.10.0' becomes 101000.  The lowest digit is
+   always zero, as is the second lowest for '10.10.x' and above.
    Print a warning if the version number can't be understood.  */
 static const char *
 version_as_macro (void)
 {
-  static char result[] = "1000";
+  static char result[7] = "1000";
+  int minorDigitIdx;
 
   if (strncmp (darwin_macosx_version_min, "10.", 3) != 0)
     goto fail;
   if (! ISDIGIT (darwin_macosx_version_min[3]))
     goto fail;
-  result[2] = darwin_macosx_version_min[3];
-  if (darwin_macosx_version_min[4] != '\0'
-      && darwin_macosx_version_min[4] != '.')
+
+  minorDigitIdx = 3;
+  result[2] = darwin_macosx_version_min[minorDigitIdx++];
+  if (ISDIGIT (darwin_macosx_version_min[minorDigitIdx]))
+  {
+    /* Starting with OS X 10.10, the macro ends '00' rather than '0',
+       i.e. 10.10.x becomes 101000 rather than 10100.  */
+    result[3] = darwin_macosx_version_min[minorDigitIdx++];
+    result[4] = '0';
+    result[5] = '0';
+    result[6] = '\0';
+  }
+  if (darwin_macosx_version_min[minorDigitIdx] != '\0'
+      && darwin_macosx_version_min[minorDigitIdx] != '.')
     goto fail;
 
   return result;
--- a/gcc/config/darwin-driver.c
+++ b/gcc/config/darwin-driver.c
@@ -29,8 +29,8 @@ along with GCC; see the file COPYING3.  If not see
 #include <sys/sysctl.h>
 #include "xregex.h"
 
-static bool
-darwin_find_version_from_kernel (char *new_flag)
+static char *
+darwin_find_version_from_kernel (void)
 {
   char osversion[32];
   size_t osversion_len = sizeof (osversion) - 1;
@@ -39,6 +39,7 @@ darwin_find_version_from_kernel (char *new_flag)
   char minor_vers[6];
   char * version_p;
   char * version_pend;
+  char * new_flag;
 
   /* Determine the version of the running OS.  If we can't, warn user,
      and do nothing.  */
@@ -46,7 +47,7 @@ darwin_find_version_from_kernel (char *new_flag)
 	      &osversion_len, NULL, 0) == -1)
     {
       warning (0, "sysctl for kern.osversion failed: %m");
-      return false;
+      return NULL;
     }
 
   /* Try to parse the first two parts of the OS version number.  Warn
@@ -57,8 +58,6 @@ darwin_find_version_from_kernel (char *new_flag)
   version_p = osversion + 1;
   if (ISDIGIT (*version_p))
     major_vers = major_vers * 10 + (*version_p++ - '0');
-  if (major_vers > 4 + 9)
-    goto parse_failed;
   if (*version_p++ != '.')
     goto parse_failed;
   version_pend = strchr(version_p, '.');
@@ -74,17 +73,16 @@ darwin_find_version_from_kernel (char *new_flag)
   if (major_vers - 4 <= 4)
     /* On 10.4 and earlier, the old linker is used which does not
        support three-component system versions.  */
-    sprintf (new_flag, "10.%d", major_vers - 4);
+    asprintf (&new_flag, "10.%d", major_vers - 4);
   else
-    sprintf (new_flag, "10.%d.%s", major_vers - 4,
-	     minor_vers);
+    asprintf (&new_flag, "10.%d.%s", major_vers - 4, minor_vers);
 
-  return true;
+  return new_flag;
 
  parse_failed:
   warning (0, "couldn%'t understand kern.osversion %q.*s",
 	   (int) osversion_len, osversion);
-  return false;
+  return NULL;
 }
 
 #endif
@@ -105,7 +103,7 @@ darwin_default_min_version (unsigned int *decoded_options_count,
   const unsigned int argc = *decoded_options_count;
   struct cl_decoded_option *const argv = *decoded_options;
   unsigned int i;
-  static char new_flag[sizeof ("10.0.0") + 6];
+  const char *new_flag;
 
   /* If the command-line is empty, just return.  */
   if (argc <= 1)
@@ -142,16 +140,16 @@ darwin_default_min_version (unsigned int *decoded_options_count,
 
 #ifndef CROSS_DIRECTORY_STRUCTURE
 
- /* Try to find the version from the kernel, if we fail - we print a message 
-    and give up.  */
- if (!darwin_find_version_from_kernel (new_flag))
-   return;
+  /* Try to find the version from the kernel, if we fail - we print a message 
+     and give up.  */
+  new_flag = darwin_find_version_from_kernel ();
+  if (!new_flag)
+    return;
 
 #else
 
- /* For cross-compilers, default to the target OS version. */
-
- strncpy (new_flag, DEF_MIN_OSX_VERSION, sizeof (new_flag));
+  /* For cross-compilers, default to the target OS version. */
+  new_flag = DEF_MIN_OSX_VERSION;
 
 #endif /* CROSS_DIRECTORY_STRUCTURE */
 
@@ -165,7 +163,6 @@ darwin_default_min_version (unsigned int *decoded_options_count,
   memcpy (*decoded_options + 2, argv + 1,
 	  (argc - 1) * sizeof (struct cl_decoded_option));
   return;
-  
 }
 
 /* Translate -filelist and -framework options in *DECODED_OPTIONS

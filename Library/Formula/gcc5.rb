class Gcc5 < Formula
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

  desc "GNU compiler collection"
  homepage "https://gcc.gnu.org"
  url "https://ftpmirror.gnu.org/gcc/gcc-5.5.0/gcc-5.5.0.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gcc/gcc-5.5.0/gcc-5.5.0.tar.xz"
  sha256 "530cea139d82fe542b358961130c69cfde8b3d14556370b65823d2f91f0ced87"

  bottle do
    sha256 "834b511f2f460db483e8126b446bb0a7fc7e2d7ee16bb53d6c4ec51910ce89be" => :el_capitan
    sha256 "b44fcce2f25919f93d33fe9482c1f9cc1068e3332f6890340853c32007c0113b" => :yosemite
    sha256 "7b4970b4c2c86558208476c3e281f242be4f6bfe7c1fa8391e52b9829ef4ba78" => :mavericks
  end

  # GCC's Go compiler is not currently supported on Mac OS X.
  # See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=46986
  option "with-java", "Build the gcj compiler"
  option "with-all-languages", "Enable all compilers and languages, except Ada"
  option "with-nls", "Build with native language support (localization)"
  option "with-profiled-build", "Make use of profile guided optimization when bootstrapping GCC"
  option "with-jit", "Build just-in-time compiler"
  option "without-fortran", "Build without the gfortran compiler"
  # enabling multilib on a host that can't run 64-bit results in build failures
  option "without-multilib", "Build without multilib support" if MacOS.prefer_64_bit?

  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "isl014"
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

  # Fix an Intel-only build failure on 10.4.
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=64184
  patch :DATA if MacOS.version < :leopard && Hardware.cpu_type == :intel

  # Fix an incompatibility with Make 3.80.
  # https://gcc.gnu.org/ml/gcc-patches/2015-07/msg01398.html
  patch do
    url "https://gist.githubusercontent.com/mistydemeo/f5508247c1171edcbddcd95671137bdb/raw/249976f5b22ace26f2373f6fad12c0a1c0e22df4/libgcc-fix-make380.patch"
    sha256 "fc5b45bb2771a6b35b0283412a50d7cb13ae982ed5607b27232a976a48078134"
  end

  # Fix for libgccjit.so linkage on Darwin.
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=64089
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/64fd2d52/gcc%405/5.4.0.patch"
    sha256 "1e126048d9a6b29b0da04595ffba09c184d338fe963cf9db8d81b47222716bc4"
  end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    # Otherwise libstdc++ will be incorrectly tagged with cpusubtype 10 (G4e)
    # https://github.com/mistydemeo/tigerbrew/issues/538
    ENV.append_to_cflags "-force_cpusubtype_ALL" if Hardware::CPU.family == :g3

    if MacOS.version < :leopard
      ENV["AS"] = ENV["AS_FOR_TARGET"] = "#{Formula["cctools"].bin}/as"
    end

    if build.with? "all-languages"
      # Everything but Ada, which requires a pre-existing GCC Ada compiler
      # (gnat) to bootstrap. GCC 4.6.0 adds Go as a language option, but it is
      # currently only compilable on Linux.
      languages = %w[c c++ fortran java objc obj-c++ jit]
    else
      # C, C++, ObjC compilers are always built
      languages = %w[c c++ objc obj-c++]

      languages << "fortran" if build.with? "fortran"
      languages << "java" if build.with? "java"
      languages << "jit" if build.with? "jit"
    end

    version_suffix = version.to_s.slice(/\d/)

    args = [
      "--build=#{arch}-apple-darwin#{osmajor}",
      "--prefix=#{prefix}",
      "--libdir=#{lib}/gcc/#{version_suffix}",
      "--enable-languages=#{languages.join(",")}",
      # Make most executables versioned to avoid conflicts.
      "--program-suffix=-#{version_suffix}",
      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc"].opt_prefix}",
      "--with-isl=#{Formula["isl014"].opt_prefix}",
      "--with-system-zlib",
      "--enable-libstdcxx-time=yes",
      "--enable-stage1-checking",
      "--enable-checking=release",
      "--enable-lto",
      # Use 'bootstrap-debug' build configuration to force stripping of object
      # files prior to comparison during bootstrap (broken by Xcode 6.3).
      "--with-build-config=bootstrap-debug",
      # A no-op unless --HEAD is built because in head warnings will
      # raise errors. But still a good idea to include.
      "--disable-werror",
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
      args << "--with-ecj-jar=#{Formula["ecj"].opt_share}/java/ecj.jar"
    end

    if build.without?("multilib") || !MacOS.prefer_64_bit?
      args << "--disable-multilib"
    else
      args << "--enable-multilib"
    end

    args << "--enable-host-shared" if build.with?("jit") || build.with?("all-languages")

    # Ensure correct install names when linking against libgcc_s;
    # see discussion in https://github.com/Homebrew/homebrew/pull/34303
    inreplace "libgcc/config/t-slibgcc-darwin", "@shlib_slibdir@", "#{HOMEBREW_PREFIX}/lib/gcc/#{version_suffix}"

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
    # Since GCC 4.8 libffi stuff are no longer shipped.
    # Rename man7.
    Dir.glob(man7/"*.7") { |file| add_suffix file, version_suffix }

    # Even when suffixes are appended, the info pages conflict when
    # install-info is run. Fix this.
    info.rmtree

    # Since GCC 4.9 java properties are properly sandboxed.
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
    system bin/"gcc-5", "-o", "hello-c", "hello-c.c"
    assert_equal "Hello, world!\n", `./hello-c`
  end
end

__END__
diff --git a/libcilkrts/runtime/sysdep-unix.c b/libcilkrts/runtime/sysdep-unix.c
index 1f82b62..41887e7 100644
--- a/libcilkrts/runtime/sysdep-unix.c
+++ b/libcilkrts/runtime/sysdep-unix.c
@@ -115,6 +115,10 @@ void *alloca (size_t);
 #   include <vxCpuLib.h>  
 #endif
 
+#ifdef __APPLE__
+#   include <sys/sysctl.h>
+#endif
+
 struct global_sysdep_state
 {
     pthread_t *threads;    ///< Array of pthreads for system workers
@@ -629,6 +633,19 @@ static const char *get_runtime_path ()
 #endif
 }
 
+#ifdef __APPLE__
+static int emulate_sysconf_nproc_onln () {
+    int count = 0;
+    int cmd[2] = { CTL_HW, HW_NCPU };
+    size_t len = sizeof count;
+    int status = sysctl(cmd, 2, &count, &len, 0, 0);
+    assert(status >= 0);
+    assert((unsigned)count == count);
+
+    return count;
+}
+#endif
+
 /* if the environment variable, CILK_VERSION, is defined, writes the version
  * information to the specified file.
  * g is the global state that was just created, and n is the number of workers
@@ -732,6 +749,8 @@ static void write_version_file (global_state_t *g, int n)
     fprintf(fp, "==================\n");
 #ifdef __VXWORKS__      
     fprintf(fp, "System cores: %d\n", (int)__builtin_popcount(vxCpuEnabledGet()));
+#elif defined __APPLE__
+    fprintf(fp, "System cores: %d\n", emulate_sysconf_nproc_onln());
 #else    
     fprintf(fp, "System cores: %d\n", (int)sysconf(_SC_NPROCESSORS_ONLN));
 #endif    

class Gcc14 < Formula
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
  url "https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz"
  sha256 "a7b39bc69cbf9e25826c5a60ab26477001f7c08d85cec04bc0e29cabed6f3cc9"

  bottle do
  end

  option "with-nls", "Build with native language support (localization)"
  # enabling multilib on a host that can't run 64-bit results in build failures
  option "without-multilib", "Build without multilib support" if MacOS.prefer_64_bit?
  # JIT fails to build on i386, or any platform for Tiger
  if !(Hardware::CPU.type == :intel && !MacOS.prefer_64_bit?) || MacOS.version > :leopard
    option "with-jit", "Build just-in-time compiler"
  end

  # System texinfo is too old
  depends_on "texinfo" => :build
  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "isl"
  # System zlib is missing crc32_combine on Tiger
  depends_on "zlib"

  if MacOS.version < :leopard
    # The as that comes with Tiger isn't capable of dealing with the
    # PPC asm that comes in libitm
    depends_on "cctools"
    # GCC invokes ld with flags the system ld doesn't have
    depends_on "ld64"
  end

  # Needs a newer tigerbrew-provided GCC to build
  fails_with :gcc_4_0
  fails_with :gcc
  fails_with :llvm

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  # Applied upstream: https://github.com/gcc-mirror/gcc/commit/1cfe4a4d0d4447b364815d5e5c889deb2e533669
  # Can remove in a later version.
  patch :p0 do
    url "https://github.com/macports/macports-ports/raw/b5a5b6679f59dcad1b21f66bb01e3f8a3a377b4b/lang/gcc14/files/darwin-ppc-fpu.patch"
    sha256 "7f14356f2e9efdf46503ca1156302c9b294db52569f4d56073267142b6d2ee71"
  end

  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=117834
  patch :p0 do
    url "https://github.com/macports/macports-ports/raw/b5a5b6679f59dcad1b21f66bb01e3f8a3a377b4b/lang/gcc14/files/darwin8-define-PTHREAD_RWLOCK_INITIALIZER.patch"
    sha256 "57ffac38f4d5eb4d92634d9e7c339f961e3eb908d13a944d622bfc6915a4f435"
  end

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  def pour_bottle?
    MacOS::CLT.installed?
  end

  def version_suffix
    version.to_s.slice(/\d\d/)
  end

  def install
    # GCC Bug 25127 for PowerPC
    # https://gcc.gnu.org/bugzilla//show_bug.cgi?id=25127
    # ../../../libgcc/unwind.inc: In function '_Unwind_RaiseException':
    # ../../../libgcc/unwind.inc:136:1: internal compiler error: in rs6000_emit_prologue, at config/rs6000/rs6000.c:26535
    # GCC 7 fails to install on 10.6 x86_64 at stage3
    # https://github.com/mistydemeo/tigerbrew/issues/554
    ENV.no_optimization

    # Otherwise libstdc++ will be incorrectly tagged with cpusubtype 10 (G4e)
    # https://github.com/mistydemeo/tigerbrew/issues/538
    if Hardware::CPU.family == :g3 || ARGV.bottle_arch == :g3
      ENV.append_to_cflags "-force_cpusubtype_ALL"
    end

    # We avoiding building:
    #  - Ada, which requires a pre-existing GCC Ada compiler to bootstrap
    #  - Go, currently not supported on macOS
    #  - BRIG
    languages = %w[c c++ objc obj-c++ fortran]

    # JIT compiler is off by default, enabling it has performance cost
    languages << "jit" if build.with? "jit"

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
      "--with-isl=#{Formula["isl"].opt_prefix}",
      "--with-system-zlib",
      "--enable-checking=release",
      "--with-pkgversion=Tigerbrew #{name} #{pkg_version} #{build.used_options*" "}".strip,
      "--with-bugurl=https://github.com/mistydemeo/tigerbrew/issues",
    ]

    # "Building GCC with plugin support requires a host that supports
    # -fPIC, -shared, -ldl and -rdynamic."
    args << "--enable-plugin" if MacOS.version > :leopard

    # Otherwise make fails during comparison at stage 3
    # See: http://gcc.gnu.org/bugzilla/show_bug.cgi?id=45248
    args << "--with-dwarf2" if MacOS.version < :leopard

    args << "--disable-nls" if build.without? "nls"

    if build.without?("multilib") || !MacOS.prefer_64_bit?
      args << "--disable-multilib"
    else
      args << "--enable-multilib"
    end

    args << "--enable-host-shared" if build.with?("jit")

    # These two flags are required for zlib to be found in the last stage
    inreplace "gcc/Makefile.in" do |s|
      s.change_make_var! "ZLIB", "-L#{Formula["zlib"].opt_lib} -lz"
      s.change_make_var! "ZLIBINC", "-I#{Formula["zlib"].opt_include}"
    end

    if MacOS.version < :leopard
      # We need to use a newer as to build, but we also want the compiler
      # to use it at runtime
      ENV["AS"] = ENV["AS_FOR_TARGET"] = "#{Formula["cctools"].bin}/as"
      # Following Macports on which tools to specify both in the environment
      # and as configure args
      args << "--with-as=#{Formula["cctools"].bin}/as"
      # We'll also configure the compiler to use the rest of the newer cctools
      ENV["AR_FOR_TARGET"] = "#{Formula["cctools"].bin}/ar"
      args << "--with-ar=#{Formula["cctools"].bin}/ar"
      ENV["NM_FOR_TARGET"] = "#{Formula["cctools"].bin}/nm"
      ENV["RANLIB_FOR_TARGET"] = "#{Formula["cctools"].bin}/ranlib"
      ENV["STRIP_FOR_TARGET"] = "#{Formula["cctools"].bin}/strip"

      # We need ld both for the build and for the end result compiler to use
      # Note that unlike the above, which are more nice-to-haves, gcc-14
      # will actually fail to use the system ld on Tiger.
      ENV.ld64
      ENV["LD_FOR_TARGET"] = ENV["LD"]
      args << "--with-ld=#{ENV["LD"]}"

      # Avoids the need for the ttyname_r patch
      # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=117857
      # https://github.com/mistydemeo/tigerbrew/pull/1286#issuecomment-2664224824
      ENV.append_to_cflags "-D__DARWIN_UNIX03"
    end

    mkdir "build" do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # "native-system-headers" will be appended
        args << "--with-native-system-header-dir=/usr/include"
        args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system "../configure", *args
      system "make"
      system "make", "install"
    end

    # Handle conflicts between GCC formulae and avoid interfering
    # with system compilers.
    # Since GCC 4.8 libffi stuff are no longer shipped.
    # Rename man7.
    Dir.glob(man7/"*.7") { |file| add_suffix file, version_suffix }
    # Even when suffixes are appended, the info pages conflict when
    # install-info is run. TODO fix this.
    info.rmtree
  end

  def add_suffix(file, suffix)
    dir = File.dirname(file)
    ext = File.extname(file)
    base = File.basename(file, ext)
    File.rename file, "#{dir}/#{base}-#{suffix}#{ext}"
  end

  def caveats
    if build.with?("multilib") then <<-EOS.undent
      GCC has been built with multilib support. Notably, OpenMP may not work:
        https://gcc.gnu.org/bugzilla/show_bug.cgi?id=60670
      If you need OpenMP support you may want to
        brew reinstall gcc --without-multilib
      EOS
    end
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
    system "#{bin}/gcc-#{version_suffix}", "-o", "hello-c", "hello-c.c"
    assert_equal "Hello, world!\n", `./hello-c`

    (testpath/"hello-cc.cc").write <<-EOS.undent
      #include <iostream>
      int main()
      {
        std::cout << "Hello, world!" << std::endl;
        return 0;
      }
    EOS
    system "#{bin}/g++-#{version_suffix}", "-o", "hello-cc", "hello-cc.cc"
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
    system "#{bin}/gfortran-8", "-o", "test", "test.f90"
    assert_equal "Done\n", `./test`
  end
end

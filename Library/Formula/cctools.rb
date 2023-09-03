class Cctools < Formula
  desc "Binary and cross-compilation tools for Apple"
  homepage "https://github.com/apple-oss-distributions/cctools/tree/cctools-806"

  if MacOS.version >= :snow_leopard
    url "https://github.com/apple-oss-distributions/cctools/archive/refs/tags/cctools-855.tar.gz"
    sha256 "7c31652cefde324fd6dc6f4dabbcd936986430039410a65c98d4a7183695f6d7"
  else
    # 806 (from Xcode 4.1) is the latest version that supports Tiger or PowerPC
    url "https://github.com/apple-oss-distributions/cctools/archive/refs/tags/cctools-806.tar.gz"
    sha256 "331b44a2df435f425ea3171688305dcb46aa3b29df2d38b421d82eb27dbd4d2e"
  end

  bottle do
    cellar :any_skip_relocation
    revision 1
    sha256 "80262f4d2c2ed5e7e9b2e80d8a0c30937f9239a3f1958010ad247a1b731e49a2" => :tiger_altivec
    sha256 "4adc7c27e720a59d8bdb177dd06b8cd5ca7ff3c0b8199e29c1b04db417966986" => :leopard_g3
    sha256 "426f3d48789f9f19bed020a3912daf6d808a8491fb86bb24ff702c9d02113aa4" => :leopard_altivec
  end

  depends_on :ld64

  cxxstdlib_check :skip

  keg_only :provided_by_osx,
    "This package duplicates tools shipped by Xcode."

  if MacOS.version >= :snow_leopard
    option "with-llvm", "Build with LTO support"
    depends_on "llvm" => :optional

    # These patches apply to cctools 855, for newer OSes
    patch :p0 do
      url "https://trac.macports.org/export/129741/trunk/dports/devel/cctools/files/cctools-829-lto.patch"
      sha256 "8ed90e0eef2a3afc810b375f9d3873d1376e16b17f603466508793647939a868"
    end

    patch :p0 do
      url "https://trac.macports.org/export/129741/trunk/dports/devel/cctools/files/PR-37520.patch"
      sha256 "921cba3546389809500449b08f4275cfd639295ace28661c4f06174b455bf3d4"
    end

    patch :p0 do
      url "https://trac.macports.org/export/129741/trunk/dports/devel/cctools/files/cctools-839-static-dis_info.patch"
      sha256 "f49162b5c5d2753cf19923ff09e90949f01379f8de5604e86c59f67441a1214c"
    end

    # Fix building libtool with LTO disabled
    patch do
      url "https://gist.githubusercontent.com/mistydemeo/9fc5589d568d2fc45fb5/raw/c752d5c4567809c10b14d623b6c2d7416211b33a/libtool-no-lto.diff"
      sha256 "3b687f2b9388ac6c4acac2b7ba28d9fd07f2a16e7d2dad09aa2255d98ec1632b"
    end

    # strnlen patch only needed on Snow Leopard
    if MacOS.version == :snow_leopard
      patch :p0 do
        url "https://trac.macports.org/export/129741/trunk/dports/devel/cctools/files/snowleopard-strnlen.patch"
        sha1 "31c083b056d4510702484436fc66f24cc8635060"
      end
    end
  else
    depends_on "cctools-headers" => :build

    # This set of patches only applies to cctools 806, for older OSes
    patch :p0 do
      url "https://trac.macports.org/export/103959/trunk/dports/devel/cctools/files/cctools-806-lto.patch"
      sha1 "f8a2059a4730119687d2ba6a5d9e7b49b66840e8"
    end

    patch :p0 do
      url "https://trac.macports.org/export/103959/trunk/dports/devel/cctools/files/PR-9087924.patch"
      sha1 "1e5040370944a84e06bd983ea9f4e544a2ea7236"
    end

    patch :p0 do
      url "https://trac.macports.org/export/103959/trunk/dports/devel/cctools/files/PR-9830754.patch"
      sha1 "65b8e2f7a877716fec82fcd2cd0c6c34adfdece3"
    end

    # Despite the patch name this is needed on 806 too
    patch :p0 do
      url "https://trac.macports.org/export/103985/trunk/dports/devel/cctools/files/cctools-822-no-lto.patch"
      sha1 "e58ee836dde4693e90a39579c20df45f067d75a1"
    end

    patch :p0 do
      url "https://trac.macports.org/export/103959/trunk/dports/devel/cctools/files/PR-11136237.patch"
      sha1 "88c045c08161d14241b7d51437b3ba77093d573a"
    end

    patch :p0 do
      url "https://trac.macports.org/export/103959/trunk/dports/devel/cctools/files/PR-12475288.patch"
      sha1 "3d6cb1ff1443b8c1c68c21c9808833537f7ce48d"
    end
  end

  def install
    ENV.j1 # see https://github.com/mistydemeo/tigerbrew/issues/102

    if build.with? "llvm"
      inreplace "libstuff/lto.c", "@@LLVM_LIBDIR@@", Formula["llvm"].opt_lib
    end

    args = %W[
      RC_ProjectSourceVersion=#{version}
      USE_DEPENDENCY_FILE=NO
      BUILD_DYLIBS=NO
      CC=#{ENV.cc}
      CXX=#{ENV.cxx}
      LTO=#{"-DLTO_SUPPORT" if build.with? "llvm"}
      RC_CFLAGS=#{ENV.cflags}
      TRIE=
      RC_OS="macos"
      DSTROOT=#{prefix}
    ]

    # Fixes build with gcc-4.2: https://trac.macports.org/ticket/43745
    args << "SDK=-std=gnu99"

    if Hardware::CPU.intel?
      archs = "i386 x86_64"
    else
      archs = "ppc i386 x86_64"
    end
    args << "RC_ARCHS=#{archs}"

    system "make", "install_tools", *args

    # cctools installs into a /-style prefix in the supplied DSTROOT,
    # so need to move the files into the standard paths.
    # Also merge the /usr and /usr/local trees.
    man.install Dir["#{prefix}/usr/local/man/*"]
    prefix.install Dir["#{prefix}/usr/local/*"]
    bin.install Dir["#{prefix}/usr/bin/*"]
    (include/"mach-o").install Dir["#{prefix}/usr/include/mach-o/*"]
    man1.install Dir["#{prefix}/usr/share/man/man1/*"]
    man3.install Dir["#{prefix}/usr/share/man/man3/*"]
    man5.install Dir["#{prefix}/usr/share/man/man5/*"]

    # These install locations changed between 806 and 855
    if MacOS.version >= :snow_leopard
      (libexec/"as").install Dir["#{prefix}/usr/libexec/as/*"]
    else
      (libexec/"gcc/darwin").install Dir["#{prefix}/usr/libexec/gcc/darwin/*"]
      share.install Dir["#{prefix}/usr/share/gprof.*"]
    end
  end

  def caveats; <<-EOS.undent
    cctools's version of ld was not built.
    EOS
  end

  test do
    assert_match "/usr/lib/libSystem.B.dylib", shell_output("#{bin}/otool -L #{bin}/install_name_tool")
  end
end

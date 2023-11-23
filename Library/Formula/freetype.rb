class Freetype < Formula
  desc "Software library to render fonts"
  homepage "http://www.freetype.org"
  url "https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.xz"
  mirror "https://download-mirror.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.xz"
  sha256 "12991c4e55c506dd7f9b765933e62fd2be2e06d421505d7950a132e4f1bb484d"

  bottle do
    cellar :any
    sha256 "bf749720281bd1928c0d122fb4160545fbb671ac7cdc0902afe29b23a849b933" => :tiger_altivec
  end

  keg_only :provided_pre_mountain_lion

  option :universal
  option "without-subpixel", "Disable sub-pixel rendering (a.k.a. LCD rendering, or ClearType)"

  depends_on "pkg-config" => :build
  depends_on "bzip2"
  depends_on "libpng"
  depends_on "zlib"

  def install
    # This file will be installed to bindir, so we want to avoid embedding the
    # absolute path to the pkg-config shim.
    inreplace "builds/unix/freetype-config.in", "%PKG_CONFIG%", "pkg-config"

    if build.with? "subpixel"
      inreplace "include/freetype/config/ftoption.h",
          "/* #define FT_CONFIG_OPTION_SUBPIXEL_RENDERING */",
          "#define FT_CONFIG_OPTION_SUBPIXEL_RENDERING"
    end

    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}",
                          "--enable-freetype-config",
                          "--without-harfbuzz"
    system "make"
    system "make", "install"

    inreplace [bin/"freetype-config", lib/"pkgconfig/freetype2.pc"],
      prefix, opt_prefix
  end

  test do
    system "#{bin}/freetype-config", "--cflags", "--libs", "--ftversion",
      "--exec-prefix", "--prefix"
  end
end

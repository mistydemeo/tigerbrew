class Freetype < Formula
  desc "Software library to render fonts"
  homepage "http://www.freetype.org"
  url "https://downloads.sf.net/project/freetype/freetype2/2.6/freetype-2.6.tar.bz2"
  mirror "http://download.savannah.gnu.org/releases/freetype/freetype-2.6.tar.bz2"
  sha256 "8469fb8124764f85029cc8247c31e132a2c5e51084ddce2a44ea32ee4ae8347e"

  bottle do
    cellar :any
    sha256 "6ebf5afadacb6dc0252b0fcb51d6c706a27f9ec591d1622f480a5ae275f82b55" => :leopard_g3
    sha256 "a09402a7a0d80223670a8b803cc62107c9b10e570a2d7af0afd5ae6829c41959" => :leopard_altivec
  end

  keg_only :provided_pre_mountain_lion

  option :universal
  option "without-subpixel", "Disable sub-pixel rendering (a.k.a. LCD rendering, or ClearType)"

  depends_on "libpng"

  def install
    if build.with? "subpixel"
      inreplace "include/config/ftoption.h",
          "/* #define FT_CONFIG_OPTION_SUBPIXEL_RENDERING */",
          "#define FT_CONFIG_OPTION_SUBPIXEL_RENDERING"
    end

    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}", "--without-harfbuzz"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/freetype-config", "--cflags", "--libs", "--ftversion",
      "--exec-prefix", "--prefix"
  end
end

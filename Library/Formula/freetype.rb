class Freetype < Formula
  desc "Software library to render fonts"
  homepage "http://www.freetype.org"
  url "https://downloads.sf.net/project/freetype/freetype2/2.6/freetype-2.6.tar.bz2"
  mirror "http://download.savannah.gnu.org/releases/freetype/freetype-2.6.tar.bz2"
  sha256 "8469fb8124764f85029cc8247c31e132a2c5e51084ddce2a44ea32ee4ae8347e"
  revision 1

  bottle do
    cellar :any
    sha256 "dfee98da99ff2fda0a7056472521ae3cd7947075403268cbffe753bc3bd339aa" => :tiger_altivec
    sha256 "4cfd87fd6da0daa50a0d75cc325fd9f1e84a68ded25509f4eebc29e45154891e" => :leopard_g3
    sha256 "24cf7d02f2c219688ee7261ce013305c826619300162617ba209d7f9f735a53a" => :leopard_altivec
  end

  keg_only :provided_pre_mountain_lion

  option :universal
  option "without-subpixel", "Disable sub-pixel rendering (a.k.a. LCD rendering, or ClearType)"

  depends_on "libpng"

  # Don't define a TYPEOF macro in ftconfig.h
  # https://savannah.nongnu.org/bugs/index.php?45376
  # http://git.savannah.gnu.org/cgit/freetype/freetype2.git/commit/?id=5931268eecaeda3e05580bdc8885348fecc43fa8
  patch do
    url "https://gist.githubusercontent.com/anonymous/b47d77c41a6801879fd2/raw/fc21c3516b465095da7ed13f98bea491a7d18bbd/patch"
    sha256 "5b21575d0384c9e502b51b0ba4be0ff453a34bcf9deba52b6baa38c3ffcde063"
  end

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

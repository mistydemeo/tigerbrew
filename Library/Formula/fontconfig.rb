class Fontconfig < Formula
  desc "XML-based font configuration API for X Windows"
  homepage "http://fontconfig.org/"
  url "https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.14.2.tar.xz"
  sha256 "dba695b57bce15023d2ceedef82062c2b925e51f5d4cc4aef736cf13f60a468b"

  bottle do
    sha256 "0203abd547ff858bf1c07d8949e1d7bd8e8303d3627b133044e03731b1a781f1" => :tiger_altivec
  end

  keg_only :provided_pre_mountain_lion

  option :universal

  depends_on "pkg-config" => :build
  depends_on "freetype"

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--with-add-fonts=/System/Library/Fonts,/Library/Fonts,~/Library/Fonts",
                          "--prefix=#{prefix}",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}"
    system "make", "install", "RUN_FC_CACHE_TEST=false"
  end

  def post_install
    system "#{bin}/fc-cache", "-frv"
  end

  test do
    system "#{bin}/fc-list"
  end
end

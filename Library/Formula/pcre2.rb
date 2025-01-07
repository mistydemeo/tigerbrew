class Pcre2 < Formula
  desc "Perl compatible regular expressions library with a new API"
  homepage "https://www.pcre.org/"
  url "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.44/pcre2-10.44.tar.bz2"
  sha256 "d34f02e113cf7193a1ebf2770d3ac527088d485d4e047ed10e5d217c6ef5de96"

  head "https://github.com/PCRE2Project/pcre2"

  bottle do
  end

  option :universal

  depends_on "bzip2"
  depends_on "zlib"

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-pcre2-16",
                          "--enable-pcre2-32",
                          "--enable-pcre2grep-libz",
                          "--enable-pcre2grep-libbz2"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/pcre2grep", "regular expression", prefix/"README"
  end
end

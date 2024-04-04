class Pcre2 < Formula
  desc "Perl compatible regular expressions library with a new API"
  homepage "https://www.pcre.org/"
  url "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.bz2"
  sha256 "8d36cd8cb6ea2a4c2bb358ff6411b0c788633a2a45dabbf1aeb4b701d1b5e840"

  head "https://github.com/PCRE2Project/pcre2"

  bottle do
    sha256 "8994bdc208954bda33063808e865b53f2f1fe3e84a5da2376d5e66275347cfb8" => :tiger_altivec
  end

  option :universal

  # Allow building with JIT support on Tiger
  patch :p0 do
   url "https://raw.githubusercontent.com/macports/macports-ports/661d0212412d4f428a37d31e233fa6ca1efd4331/devel/pcre/files/no-OSCacheControl-on-tiger.diff"
   sha256 "eac8b57207586f537382ebce98b0f36476bd50118e349fd8153980a2fc65be02"
  end

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-pcre2-16",
                          "--enable-pcre2-32",
                          "--enable-pcre2grep-libz",
                          "--enable-pcre2grep-libbz2",
                          "--enable-jit"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/pcre2grep", "regular expression", prefix/"README"
  end
end

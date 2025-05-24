class Slrn < Formula
  desc "Powerful console-based newsreader"
  homepage "http://slrn.sourceforge.net/"
  url "http://jedsoft.org/releases/slrn/slrn-1.0.2.tar.bz2"
  sha256 "99acbc51e7212ccc5c39556fa8ec6ada772f0bb5cc45a3bb90dadb8fe764fb59"

  head "git://git.jedsoft.org/git/slrn.git"


  depends_on "s-lang"
  depends_on "openssl"

  def install
    bin.mkpath
    man1.mkpath
    mkdir_p "#{var}/spool/news/slrnpull"

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}",
                          "--with-slrnpull=#{var}/spool/news/slrnpull",
                          "--with-slang=#{HOMEBREW_PREFIX}"
    system "make", "all", "slrnpull"

    ENV.deparallelize
    system "make", "install"
  end

  test do
    ENV["TERM"] = "xterm"
    system bin/"slrn", "--show-config"
  end
end

class Texi2html < Formula
  desc "Convert TeXinfo files to HTML"
  homepage "http://www.nongnu.org/texi2html/"
  url "http://download.savannah.gnu.org/releases/texi2html/texi2html-1.82.tar.gz"
  sha256 "6c7c94a2d88ffe218a33e91118c2b039336cbe3f2f8b4e3a78e4fd1502072936"

  bottle do
    sha1 "dab75b6b742681e2808178d0c2ea659ac20ccf19" => :tiger_altivec
    sha1 "58cb2e4901212c31394dfdf317d1394a365eb98c" => :leopard_g3
    sha1 "59304169ba3f1d720f2e0db52f41204a0d275e5e" => :leopard_altivec
  end

  keg_only :provided_pre_mountain_lion

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--mandir=#{man}", "--infodir=#{info}"
    system "make", "install"
  end

  test do
    system "#{bin}/texi2html", "--help"
  end
end

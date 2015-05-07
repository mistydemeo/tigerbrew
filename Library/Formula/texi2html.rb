require 'formula'

class Texi2html < Formula
  homepage 'http://www.nongnu.org/texi2html/'
  url 'http://download.savannah.gnu.org/releases/texi2html/texi2html-1.82.tar.gz'
  sha1 'e7bbe1197147566250abd5c456b94c8e37e0a81f'

  bottle do
    sha1 "dab75b6b742681e2808178d0c2ea659ac20ccf19" => :tiger_altivec
  end

  keg_only :provided_pre_mountain_lion

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--mandir=#{man}", "--infodir=#{info}"
    system "make install"
  end

  test do
    system "#{bin}/texi2html", "--help"
  end
end

class Mftrace < Formula
  desc "Trace TeX bitmap font to PFA, PFB, or TTF font"
  homepage "http://lilypond.org/mftrace/"
  url "http://lilypond.org/download/sources/mftrace/mftrace-1.2.18.tar.gz"
  sha256 "0d31065f1d35919e311d9170bbfcdacc58736e3f783311411ed1277aa09d3261"
  revision 1


  depends_on "potrace"
  depends_on "t1utils"
  depends_on "fontforge" => [:recommended, :run]

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/mftrace", "--version"
  end
end

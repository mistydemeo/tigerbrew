class Libvoikko < Formula
  desc "Linguistic software for Finnish"
  homepage "http://voikko.puimula.org/"
  url "http://www.puimula.org/voikko-sources/libvoikko/libvoikko-3.8.tar.gz"
  sha256 "1df2f4a47217d1de5978e1586c1bbf61a1454cef6aadadbda6aec45738e69cff"


  depends_on "pkg-config" => :build
  depends_on "suomi-malaga-voikko"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-dictionary-path=#{HOMEBREW_PREFIX}/lib/voikko"
    system "make", "install"
  end
end

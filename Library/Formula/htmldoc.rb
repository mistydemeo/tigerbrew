class Htmldoc < Formula
  desc "Convert HTML to PDF or PostScript"
  homepage "https://www.msweet.org/htmldoc/"
  url "http://www.msweet.org/files/project1/htmldoc-1.8.28-source.tar.bz2"
  sha256 "2a688bd820ad6f7bdebb274716102dafbf4d5fcfa20a5b8d87a56b030d184732"
  revision 2

  depends_on "libpng"
  depends_on "jpeg"

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make"
    system "make", "install"
  end
end

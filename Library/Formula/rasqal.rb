class Rasqal < Formula
  desc "RDF query library"
  homepage "http://librdf.org/rasqal/"
  url "http://download.librdf.org/source/rasqal-0.9.33.tar.gz"
  sha256 "6924c9ac6570bd241a9669f83b467c728a322470bf34f4b2da4f69492ccfd97c"


  depends_on "pkg-config" => :build
  depends_on "raptor"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-html-dir=#{share}/doc",
                          "--disable-dependency-tracking"
    system "make", "install"
  end
end

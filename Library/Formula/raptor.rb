class Raptor < Formula
  desc "RDF parser toolkit"
  homepage "http://librdf.org/raptor/"
  url "http://download.librdf.org/source/raptor2-2.0.15.tar.gz"
  sha256 "ada7f0ba54787b33485d090d3d2680533520cd4426d2f7fb4782dd4a6a1480ed"


  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

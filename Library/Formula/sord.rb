class Sord < Formula
  desc "C library for storing RDF data in memory"
  homepage "http://drobilla.net/software/sord/"
  url "http://download.drobilla.net/sord-0.12.2.tar.bz2"
  sha256 "bd0538d37de5e782023a7261d8ee9d83a792a12eeea7d94dec7a93dd9cda0767"


  depends_on "pkg-config" => :build
  depends_on "pcre"
  depends_on "serd"

  def install
    system "./waf", "configure", "--prefix=#{prefix}"
    system "./waf"
    system "./waf", "install"
  end
end

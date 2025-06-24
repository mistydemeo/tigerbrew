class Lilv < Formula
  desc "C library to use LV2 plugins"
  homepage "http://drobilla.net/software/lilv/"
  url "http://download.drobilla.net/lilv-0.20.0.tar.bz2"
  sha256 "428a39f1265d44c55f2604829a12ade0ea13e1a1022ff937ca2a9ad227bd422a"


  depends_on "pkg-config" => :build
  depends_on "lv2"
  depends_on "serd"
  depends_on "sord"
  depends_on "sratom"

  def install
    system "./waf", "configure", "--prefix=#{prefix}"
    system "./waf"
    system "./waf", "install"
  end
end

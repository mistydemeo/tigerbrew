class Sratom < Formula
  desc "Library for serializing LV2 atoms to/from RDF"
  homepage "http://drobilla.net/software/sratom/"
  url "http://download.drobilla.net/sratom-0.4.6.tar.bz2"
  sha256 "a4b9beaeaedc4f651beb15cd1cfedff905b0726a9010548483475ad97d941220"


  depends_on "pkg-config" => :build
  depends_on "lv2"
  depends_on "serd"
  depends_on "sord"

  def install
    system "./waf", "configure", "--prefix=#{prefix}"
    system "./waf"
    system "./waf", "install"
  end
end

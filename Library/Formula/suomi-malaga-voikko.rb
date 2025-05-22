class SuomiMalagaVoikko < Formula
  desc "Linguistic software and data for Finnish"
  homepage "http://voikko.puimula.org/"
  url "http://www.puimula.org/voikko-sources/suomi-malaga/suomi-malaga-1.18.tar.gz"
  sha256 "83655d56aa8255d8926ad3bafa190b8d7da32a0e3ff12150dc2dac31c92c5b0d"

  head "https://github.com/voikko/corevoikko.git"


  depends_on "malaga"

  def install
    Dir.chdir "suomimalaga" if build.head?
    system "make", "voikko"
    system "make", "voikko-install", "DESTDIR=#{lib}/voikko"
  end
end

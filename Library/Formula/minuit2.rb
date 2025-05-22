class Minuit2 < Formula
  desc "Physics analysis tool for function minimization"
  homepage "http://lcgapp.cern.ch/project/cls/work-packages/mathlibs/minuit/index.html"
  url "https://www.cern.ch/mathlibs/sw/5_34_14/Minuit2/Minuit2-5.34.14.tar.gz"
  sha256 "2ca9a283bbc315064c0a322bc4cb74c7e8fd51f9494f7856e5159d0a0aa8c356"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--with-pic",
                          "--disable-openmp",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

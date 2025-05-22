class Gecode < Formula
  desc "Toolkit for developing constraint-based systems and applications"
  homepage "http://www.gecode.org/"
  url "http://www.gecode.org/download/gecode-4.4.0.tar.gz"
  sha256 "430398d6900b999f92c6329636f3855f2d4e985fed420a6c4d42b46bfc97782a"


  def install
    system "./configure", "--prefix=#{prefix}", "--disable-examples"
    system "make", "install"
  end
end

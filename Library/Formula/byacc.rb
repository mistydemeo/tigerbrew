class Byacc < Formula
  desc "(Arguably) the best yacc variant"
  homepage "http://invisible-island.net/byacc/byacc.html"
  url "ftp://invisible-island.net/byacc/byacc-20141128.tgz"
  sha256 "f517fc21f08c1a1f010177357df58fc64eb1131011e5dcd48c19fe44c47198d0"


  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--program-prefix=b", "--prefix=#{prefix}", "--man=#{man}"
    system "make", "install"
  end

  test do
    system bin/"byacc", "-V"
  end
end

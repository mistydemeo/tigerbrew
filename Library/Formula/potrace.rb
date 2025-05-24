class Potrace < Formula
  desc "Convert bitmaps to vector graphics"
  homepage "http://potrace.sourceforge.net"
  url "http://potrace.sourceforge.net/download/1.12/potrace-1.12.tar.gz"
  sha256 "b0bbf1d7badbebfcb992280f038936281b47ddbae212e8ae91e863ce0b76173b"


  resource "head.pbm" do
    url "http://potrace.sourceforge.net/img/head.pbm"
    sha256 "3c8dd6643b43cf006b30a7a5ee9604efab82faa40ac7fbf31d8b907b8814814f"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--with-libpotrace"
    system "make", "install"
  end

  test do
    resource("head.pbm").stage testpath
    system "#{bin}/potrace", "-o", "test.eps", "head.pbm"
    assert File.exist? "test.eps"
  end
end

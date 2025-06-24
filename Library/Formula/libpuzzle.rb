class Libpuzzle < Formula
  desc "Library to find visually similar images"
  homepage "http://libpuzzle.pureftpd.org/project/libpuzzle"
  url "http://download.pureftpd.org/pub/pure-ftpd/misc/libpuzzle/releases/libpuzzle-0.11.tar.bz2"
  sha256 "ba628268df6956366cbd44ae48c3f1bab41e70b4737041a1f33dac9832c44781"


  depends_on "gd"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

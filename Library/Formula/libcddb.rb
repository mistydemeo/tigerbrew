class Libcddb < Formula
  desc "CDDB server access library"
  homepage "http://libcddb.sourceforge.net/"
  url "https://downloads.sourceforge.net/libcddb/libcddb-1.3.2.tar.bz2"
  sha256 "35ce0ee1741ea38def304ddfe84a958901413aa829698357f0bee5bb8f0a223b"


  depends_on "pkg-config" => :build
  depends_on "libcdio"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

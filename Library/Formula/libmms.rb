class Libmms < Formula
  desc "Library for parsing mms:// and mmsh:// network streams"
  homepage "http://sourceforge.net/projects/libmms/"
  url "https://downloads.sourceforge.net/project/libmms/libmms/0.6.4/libmms-0.6.4.tar.gz"
  sha256 "3c05e05aebcbfcc044d9e8c2d4646cd8359be39a3f0ba8ce4e72a9094bee704f"


  depends_on "pkg-config" => :build
  depends_on "glib"

  # https://trac.macports.org/ticket/27988
  patch :p0 do
    url "https://trac.macports.org/export/87883/trunk/dports/multimedia/libmms/files/src_mms-common.h.patch"
    sha1 "57b526dc9de76cfde236d3331e18eb7ae92f999f"
  end if MacOS.version <= :leopard

  def install
    ENV.append "LDFLAGS", "-liconv"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

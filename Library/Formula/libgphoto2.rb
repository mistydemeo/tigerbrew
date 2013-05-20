require 'formula'

class Libgphoto2 < Formula
  homepage 'http://www.gphoto.org/proj/libgphoto2/'
  url 'http://downloads.sourceforge.net/project/gphoto/libgphoto/2.5.2/libgphoto2-2.5.2.tar.bz2'
  sha1 '6b70ff6feec62a955bef1fc9a2b16dd07f0e277a'

  depends_on 'pkg-config' => :build
  depends_on :libtool # Configure script uses this
  depends_on 'libusb-compat'
  depends_on 'libexif' => :optional

  # Fixes http://sourceforge.net/p/gphoto/bugs/935; remove on next release
  def patches
    {:p0 => "http://sourceforge.net/p/gphoto/bugs/935/attachment/xx.pat"}
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}", "CFLAGS=-D_DARWIN_C_SOURCE"
    system "make install"
  end
end

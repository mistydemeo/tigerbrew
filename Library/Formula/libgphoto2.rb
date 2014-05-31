require 'formula'

class Libgphoto2 < Formula
  homepage 'http://www.gphoto.org/proj/libgphoto2/'
  url 'http://downloads.sourceforge.net/project/gphoto/libgphoto/2.5.1/libgphoto2-2.5.1.tar.bz2'
  sha1 '22ea99af344ca712db4d87a506ca2fc34c70e61a'

  option :universal

  depends_on 'pkg-config' => :build
  depends_on 'libtool' => :run
  depends_on 'libusb-compat'
  depends_on 'gd'
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

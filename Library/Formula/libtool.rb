# Xcode 4.3 provides the Apple libtool.
# This is not the same so as a result we must install this as glibtool.

class Libtool < Formula
  desc "Generic library support script"
  homepage "https://www.gnu.org/software/libtool/"
  url "http://ftpmirror.gnu.org/libtool/libtool-2.4.7.tar.xz"
  mirror "https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz"
  sha256 "4f7f217f057ce655ff22559ad221a0fd8ef84ad1fc5fcb6990cecc333aa1635d"

  bottle do
    cellar :any
  end

  depends_on "m4" if MacOS.version < :leopard

  keg_only :provided_until_xcode43

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--program-prefix=g",
                          "--enable-ltdl-install"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    In order to prevent conflicts with Apple's own libtool we have prepended a "g"
    so, you have instead: glibtool and glibtoolize.
    EOS
  end

  test do
    system "#{bin}/glibtool", "execute", "/usr/bin/true"
  end
end

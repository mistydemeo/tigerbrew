# Xcode 4.3 provides the Apple libtool.
# This is not the same so as a result we must install this as glibtool.

class Libtool < Formula
  desc "Generic library support script"
  homepage "https://www.gnu.org/software/libtool/"
  url "http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.xz"
  mirror "https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz"
  sha256 "7c87a8c2c8c0fc9cd5019e402bed4292462d00a718a7cd5f11218153bf28b26f"

  bottle do
    cellar :any
    sha256 "9e483f1712bc2a917f9183f80d3536f2e778dfbe9c89b82d7538354791b704e9" => :tiger_altivec
    sha256 "312ee20c1208b8de8cb545513015460d68dff99aafed509999dc8d9826b92217" => :leopard_g3
    sha256 "f14f7c9f863be4c820839eb403e5a994986f8c4d2d19ff60ea011adcceb2ed81" => :leopard_altivec
  end

  depends_on "homebrew/dupes/m4" if MacOS.version < :leopard

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

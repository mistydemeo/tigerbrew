# Xcode 4.3 provides the Apple libtool.
# This is not the same so as a result we must install this as glibtool.

class Libtool < Formula
  desc "Generic library support script"
  homepage "https://www.gnu.org/software/libtool/"
  url "http://ftpmirror.gnu.org/libtool/libtool-2.5.4.tar.xz"
  mirror "https://ftp.gnu.org/gnu/libtool/libtool-2.5.4.tar.xz"
  sha256 "f81f5860666b0bc7d84baddefa60d1cb9fa6fceb2398cc3baca6afaa60266675"
  license "GPL-2.0-or-later"

  bottle do
    cellar :any
  end

  depends_on "m4"

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

    (testpath/"hello.c").write <<~C
      #include <stdio.h>
      int main() { puts("Hello, world!"); return 0; }
    C

    system bin/"glibtool", "--mode=compile", "--tag=CC",
      ENV.cc, "-c", "hello.c", "-o", "hello.o"
    system bin/"glibtool", "--mode=link", "--tag=CC",
      ENV.cc, "hello.o", "-o", "hello"
    assert_match "Hello, world!", shell_output("./hello")

    system bin/"glibtoolize", "--ltdl"
  end
end

class Libunistring < Formula
  desc "C string library for manipulating Unicode strings"
  homepage "https://www.gnu.org/software/libunistring/"
  url "http://ftpmirror.gnu.org/libunistring/libunistring-1.3.tar.xz"
  mirror "https://ftp.gnu.org/gnu/libunistring/libunistring-1.3.tar.xz"
  sha256 "f245786c831d25150f3dfb4317cda1acc5e3f79a5da4ad073ddca58886569527"

  bottle do
    cellar :any
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

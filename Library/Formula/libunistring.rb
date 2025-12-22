class Libunistring < Formula
  desc "C string library for manipulating Unicode strings"
  homepage "https://www.gnu.org/software/libunistring/"
  url "http://ftpmirror.gnu.org/libunistring/libunistring-1.3.tar.xz"
  mirror "https://ftp.gnu.org/gnu/libunistring/libunistring-1.3.tar.xz"
  sha256 "f245786c831d25150f3dfb4317cda1acc5e3f79a5da4ad073ddca58886569527"

  bottle do
    sha256 "a159d9e400668467437b69506d03dee24186daeaab57212e12f4ae2a2540ee3b" => :tiger_altivec
    sha256 "c0dad18695671294f42167ba1ad917bb77fc8a84603eb1232569f54cb5f2e976" => :tiger_g3
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

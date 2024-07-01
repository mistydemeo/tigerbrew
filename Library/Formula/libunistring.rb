class Libunistring < Formula
  desc "C string library for manipulating Unicode strings"
  homepage "https://www.gnu.org/software/libunistring/"
  url "http://ftpmirror.gnu.org/libunistring/libunistring-1.2.tar.xz"
  mirror "https://ftp.gnu.org/gnu/libunistring/libunistring-1.2.tar.xz"
  sha256 "632bd65ed74a881ca8a0309a1001c428bd1cbd5cd7ddbf8cedcd2e65f4dcdc44"

  bottle do
    cellar :any
    sha256 "8074558a34abdb2121379dd2df80fc1572d62983f39e750b37e69f20cc8fa35c" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

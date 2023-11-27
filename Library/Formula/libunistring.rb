class Libunistring < Formula
  desc "C string library for manipulating Unicode strings"
  homepage "https://www.gnu.org/software/libunistring/"
  url "http://ftpmirror.gnu.org/libunistring/libunistring-0.9.6.tar.xz"
  mirror "https://ftp.gnu.org/gnu/libunistring/libunistring-0.9.6.tar.xz"
  sha256 "2df42eae46743e3f91201bf5c100041540a7704e8b9abfd57c972b2d544de41b"

  bottle do
    cellar :any
    sha256 "45c12000e1d272442f1f3f526164c189ee2a54a620ba47e52f8497b5c5678b06" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

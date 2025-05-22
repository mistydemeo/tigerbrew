class Cmockery2 < Formula
  desc "Reviving cmockery unit test framework from Google"
  homepage "https://github.com/lpabon/cmockery2"
  head "https://github.com/lpabon/cmockery2.git"
  url "https://github.com/lpabon/cmockery2/archive/v1.3.9.tar.gz"
  sha256 "c38054768712351102024afdff037143b4392e1e313bdabb9380cab554f9dbf2"


  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
    (share+"example").install "src/example/calculator.c"
  end

  test do
    system ENV.cc, share+"example/calculator.c", "-lcmockery", "-o", "calculator"
    system "./calculator"
  end
end

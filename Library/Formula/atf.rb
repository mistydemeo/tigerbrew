class Atf < Formula
  desc "ATF: Automated Testing Framework"
  homepage "https://github.com/jmmv/atf"
  url "https://github.com/jmmv/atf/releases/download/atf-0.21/atf-0.21.tar.gz"
  sha256 "92bc64180135eea8fe84c91c9f894e678767764f6dbc8482021d4dde09857505"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"
    system "make"
    ENV.j1
    system "make", "install"
  end
end

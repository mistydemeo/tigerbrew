class Chmlib < Formula
  desc "Library for dealing with Microsoft ITSS/CHM files"
  homepage "http://www.jedrea.com/chmlib"
  url "http://www.jedrea.com/chmlib/chmlib-0.40.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/c/chmlib/chmlib_0.40.orig.tar.gz"
  sha256 "512148ed1ca86dea051ebcf62e6debbb00edfdd9720cde28f6ed98071d3a9617"


  def install
    system "./configure", "--disable-io64", "--enable-examples", "--prefix=#{prefix}"
    system "make", "install"
  end
end

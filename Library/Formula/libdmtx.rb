class Libdmtx < Formula
  desc "Data Matrix library"
  homepage "http://www.libdmtx.org"
  url "https://downloads.sourceforge.net/project/libdmtx/libdmtx/0.7.4/libdmtx-0.7.4.tar.bz2"
  sha256 "b62c586ac4fad393024dadcc48da8081b4f7d317aa392f9245c5335f0ee8dd76"


  depends_on "pkg-config" => :build

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

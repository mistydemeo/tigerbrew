class Libp11 < Formula
  desc "PKCS#11 wrapper library in C"
  homepage "https://github.com/OpenSC/libp11/wiki"
  url "https://downloads.sourceforge.net/project/opensc/libp11/libp11-0.2.8.tar.gz"
  sha256 "a4121015503ade98074b5e2a2517fc8a139f8b28aed10021db2bb77283f40691"
  revision 1


  head do
    url "https://github.com/OpenSC/libp11.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libtool" => :run
  depends_on "openssl"

  def install
    system "./bootstrap" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

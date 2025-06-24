class Libmetalink < Formula
  desc "C library to parse Metalink XML files"
  homepage "https://launchpad.net/libmetalink/"
  url "https://launchpad.net/libmetalink/trunk/packagingfix/+download/libmetalink-0.1.2.tar.bz2"
  sha256 "cbed9121bf550ef14a434d6ed3d8806ded7a339db16b698cfa2f39fdc3d48bf6"


  depends_on "pkg-config" => :build

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

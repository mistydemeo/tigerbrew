class Theora < Formula
  desc "Open video compression format"
  homepage "http://www.theora.org/"
  url "http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2"
  sha256 "b6ae1ee2fa3d42ac489287d3ec34c5885730b1296f0801ae577a35193d3affbc"


  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "libogg"
  depends_on "libvorbis"

  def install
    cp Dir["#{Formula["libtool"].opt_share}/libtool/*/config.{guess,sub}"], buildpath
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-oggtest",
                          "--disable-vorbistest",
                          "--disable-examples"
    system "make", "install"
  end
end

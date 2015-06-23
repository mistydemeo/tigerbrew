require 'formula'

class Libvorbis < Formula
  desc "Vorbis General Audio Compression Codec"
  homepage 'http://vorbis.com'
  url 'http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.xz'
  sha256 '54f94a9527ff0a88477be0a71c0bab09a4c3febe0ed878b24824906cd4b0e1d1'

  bottle do
    cellar :any
    sha256 "451cecb555c4adb44678482b097c4ce02675d3e30789ae3f50e400592681fbbf" => :leopard_g3
    sha256 "d5fc576ca9cbbae385155b13eb90dbaccd600c78b197944c504c1e29c9decae2" => :leopard_altivec
  end

  head do
    url 'http://svn.xiph.org/trunk/vorbis'

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  depends_on 'pkg-config' => :build
  depends_on 'libogg'

  def install
    ENV.universal_binary if build.universal?

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end

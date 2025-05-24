class Libshout < Formula
  desc "Data and connectivity library for the icecast server"
  homepage "http://www.icecast.org/"
  url "http://downloads.xiph.org/releases/libshout/libshout-2.3.1.tar.gz"
  sha256 "cf3c5f6b4a5e3fcfbe09fb7024aa88ad4099a9945f7cb037ec06bcee7a23926e"


  depends_on "pkg-config" => :build
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "theora"
  depends_on "speex"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end

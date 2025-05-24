class Icecast < Formula
  desc "Streaming MP3 audio server"
  homepage "http://www.icecast.org/"
  url "http://downloads.xiph.org/releases/icecast/icecast-2.4.2.tar.gz"
  sha256 "aa1ae2fa364454ccec61a9247949d19959cb0ce1b044a79151bf8657fd673f4f"


  depends_on "pkg-config" => :build
  depends_on "libogg" => :optional
  depends_on "theora" => :optional
  depends_on "speex"  => :optional
  depends_on "openssl"
  depends_on "libvorbis"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"

    (prefix+"var/log/icecast").mkpath
    touch prefix+"var/log/icecast/error.log"
  end
end

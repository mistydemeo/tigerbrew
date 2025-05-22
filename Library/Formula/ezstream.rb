class Ezstream < Formula
  desc "Client for Icecast streaming servers"
  homepage "http://www.icecast.org/ezstream.php"
  url "http://downloads.xiph.org/releases/ezstream/ezstream-0.6.0.tar.gz"
  sha256 "f86eb8163b470c3acbc182b42406f08313f85187bd9017afb8b79b02f03635c9"


  depends_on "pkg-config" => :build
  depends_on "libvorbis"
  depends_on "libshout"
  depends_on "theora"
  depends_on "speex"
  depends_on "libogg"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.m3u").write "#{test_fixtures("test.mp3")}"
    system bin/"ezstream", "-s", testpath/"test.m3u"
  end
end

class Faac < Formula
  desc "ISO AAC audio encoder"
  homepage "http://www.audiocoding.com/faac.html"
  url "https://downloads.sourceforge.net/project/faac/faac-src/faac-1.28/faac-1.28.tar.gz"
  sha256 "c5141199f4cfb17d749c36ba8cfe4b25f838da67c22f0fec40228b6b9c3d19df"


  # Tiger's ld gives "ld: unknown flag: -compatibility_version"
  depends_on :ld64

  # gcc 4.0 can't parse faac's mp4v2/mp4.h
  # e.g.: https://gist.github.com/shirleyallan/6920853
  fails_with :gcc_4_0

  def install
    # This actually breaks faac!
    ['CFLAGS','CPPFLAGS','CXXFLAGS'].each {|f| ENV.remove f, '-faltivec'}

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"

    # libtool ignores our LDFLAGS :(
    inreplace "libtool" do |s|
      s.change_make_var! 'wl', "-B#{Formula['ld64'].bin}/ -Wl,"
    end if MacOS.version < :leopard

    system "make", "install"
  end

  test do
    system bin/"faac", test_fixtures("test.mp3"), "-P", "-o", "test.m4a"
    assert File.exist?("test.m4a")
  end
end

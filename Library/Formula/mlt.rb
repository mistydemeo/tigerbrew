class Mlt < Formula
  desc "Author, manage, and run multitrack audio/video compositions"
  homepage "http://www.mltframework.org/"
  url "https://downloads.sourceforge.net/mlt/mlt/mlt-0.9.6.tar.gz"
  sha256 "ab999992828a03dadbf62f6a131aada776cfd7afe63a94d994877fdba31a3000"


  depends_on "pkg-config" => :build

  depends_on "ffmpeg"
  depends_on "frei0r"
  depends_on "libdv"
  depends_on "libsamplerate"
  depends_on "libvorbis"
  depends_on "sdl"
  depends_on "sox"

  def install
    args = ["--prefix=#{prefix}",
            "--disable-jackrack",
            "--disable-swfdec",
            "--disable-gtk"]

    system "./configure", *args

    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/melt", "-version"
  end
end

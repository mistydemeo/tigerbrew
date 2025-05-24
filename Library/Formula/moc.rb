class Moc < Formula
  desc "Terminal-based music player"
  homepage "http://moc.daper.net"
  url "http://ftp.daper.net/pub/soft/moc/stable/moc-2.5.0.tar.bz2"
  sha256 "d29ea52240af76c4aa56fa293553da9d66675823e689249cee5f8a60657a6091"


  head do
    url "svn://daper.net/moc/trunk"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
  end

  option "with-ncurses", "Build with wide character support."

  depends_on "pkg-config" => :build
  depends_on "libtool" => :run
  depends_on "berkeley-db"
  depends_on "jack"
  depends_on "ffmpeg" => :recommended
  depends_on "mad" => :optional
  depends_on "flac" => :optional
  depends_on "speex" => :optional
  depends_on "musepack" => :optional
  depends_on "libsndfile" => :optional
  depends_on "wavpack" => :optional
  depends_on "faad2" => :optional
  depends_on "timidity" => :optional
  depends_on "libmagic" => :optional
  depends_on "ncurses" => :optional

  def install
    system "autoreconf", "-fvi" if build.head?
    system "./configure", "--disable-debug", "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats
    <<-EOS.undent
        You must start the jack daemon prior to running mocp.
        If you need wide-character support in the player, for example
        with Chinese characters, you can install using
            --with-ncurses
    EOS
  end
end

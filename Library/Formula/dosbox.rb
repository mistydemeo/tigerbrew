class Dosbox < Formula
  desc "An x86 emulator with DOS"
  homepage "https://dosbox.com"
  url "https://sourceforge.net/projects/dosbox/files/dosbox/0.74-3/dosbox-0.74-3.tar.gz"
  version "0.74-3"
  sha256 "c0d13dd7ed2ed363b68de615475781e891cd582e8162b5c3669137502222260a"

  depends_on "sdl"
  depends_on "sdl_net"
  depends_on "sdl_sound"
  depends_on "ncurses"
  depends_on "libpng"
  depends_on "zlib"


  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

class Orc < Formula
  desc "Oil Runtime Compiler (ORC)"
  homepage "http://cgit.freedesktop.org/gstreamer/orc/"
  url "http://gstreamer.freedesktop.org/src/orc/orc-0.4.23.tar.xz"
  sha256 "767eaebce2941737b43368225ec54598b3055ca78b4dc50c4092f5fcdc0bdfe7"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-gtk-doc"
    system "make", "install"
  end
end

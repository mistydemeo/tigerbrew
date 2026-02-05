class Nano < Formula
  desc "Free (GNU) replacement for the Pico text editor"
  homepage "https://www.nano-editor.org/"
  url "https://www.nano-editor.org/dist/v8/nano-8.7.1.tar.xz"
  sha256 "76f0dcb248f2e2f1251d4ecd20fd30fb400a360a3a37c6c340e0a52c2d1cdedf"
  license "GPL-3.0-or-later"

  bottle do
    sha256 "0e9baf657e025238b59d3e8f8da98835980c8f5c02ad2f2847469717032a4f0e" => :tiger_g3
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "ncurses"
  depends_on "libmagic"
  depends_on "zlib"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--enable-color",
                          "--enable-extra",
                          "--enable-multibuffer",
                          "--enable-nanorc",
                          "--enable-utf8"
    system "make", "install"
    doc.install "doc/sample.nanorc"
  end

  test do
    system "#{bin}/nano", "--version"
  end
end

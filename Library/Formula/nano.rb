class Nano < Formula
  desc "Free (GNU) replacement for the Pico text editor"
  homepage "https://www.nano-editor.org/"
  url "https://www.nano-editor.org/dist/v8/nano-8.7.tar.xz"
  sha256 "afd287aa672c48b8e1a93fdb6c6588453d527510d966822b687f2835f0d986e9"
  license "GPL-3.0-or-later"

  bottle do
    sha256 "8f703a4ff4de0aa7b140a5122ad97a7946be8118744d844cc1a8f5ffd322b02e" => :tiger_altivec
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

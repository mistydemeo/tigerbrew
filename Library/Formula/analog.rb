class Analog < Formula
  desc "Logfile analyzer"
  homepage "https://tracker.debian.org/pkg/analog"
  # The previous long-time homepage and url are stone-cold dead. Using Debian instead.
  # homepage "http://analog.cx"
  url "https://mirrors.kernel.org/debian/pool/main/a/analog/analog_6.0.orig.tar.gz"
  sha256 "31c0e2bedd0968f9d4657db233b20427d8c497be98194daf19d6f859d7f6fcca"
  revision 2


  depends_on "gd"
  depends_on "jpeg"
  depends_on "libpng"

  def install
    system "make", "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "DEFS='-DLANGDIR=\"#{share/"analog/lang/"}\"' -DHAVE_ZLIB",
                   "LIBS=-lz",
                   "OS=OSX"
    bin.install "analog"
    (share/"analog").install "examples", "how-to", "images", "lang"
    (share/"analog").install "analog.cfg" => "analog.cfg-dist"
    man1.install "analog.man" => "analog.1"
  end

  test do
    system "\"#{bin}/analog\" > /dev/null"
  end
end

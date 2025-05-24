class Minimodem < Formula
  desc "General-purpose software audio FSK modem"
  homepage "http://www.whence.com/minimodem/"
  url "http://www.whence.com/minimodem/minimodem-0.22.1.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/m/minimodem/minimodem_0.22.1.orig.tar.gz"
  sha256 "f41dd27367ffe1607c6b631bb7ab6e1c5c099490e295ce1b603cc54416845ce9"


  depends_on "pkg-config" => :build
  depends_on "libsndfile"
  depends_on "fftw"
  depends_on "pulseaudio"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-alsa"
    system "make", "install"
  end

  test do
    system "#{bin}/minimodem", "--benchmarks"
  end
end

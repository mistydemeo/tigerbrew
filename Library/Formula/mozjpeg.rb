class Mozjpeg < Formula
  desc "Improved JPEG encoder"
  homepage "https://github.com/mozilla/mozjpeg"
  url "https://github.com/mozilla/mozjpeg/releases/download/v3.1/mozjpeg-3.1-release-source.tar.gz"
  sha256 "deedd88342c5da219f0047d9a290cd58eebe1b7a513564fcd8ebc49670077a1f"

  head do
    url "https://github.com/mozilla/mozjpeg.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end


  depends_on "pkg-config" => :build
  depends_on "libpng" => :optional

  keg_only "mozjpeg is not linked to prevent conflicts with the standard libjpeg."

  # https://github.com/mozilla/mozjpeg/issues/175
  # https://github.com/Homebrew/homebrew/issues/39939
  resource "nasm" do
    url "http://www.nasm.us/pub/nasm/releasebuilds/2.11.06/nasm-2.11.06.tar.xz"
    sha256 "90f60d95a15b8a54bf34d87b9be53da89ee3d6213ea739fb2305846f4585868a"
  end

  def install
    resource("nasm").stage do
      system "./configure", "--prefix=#{buildpath}/nasm"
      system "make", "install"
    end

    ENV.prepend_path "PATH", buildpath/"nasm/bin"

    system "autoreconf", "-i" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--with-jpeg8"
    system "make", "install"
  end

  test do
    system "#{bin}/jpegtran", "-crop", "1x1",
                              "-transpose", "-optimize",
                              "-outfile", "out.jpg",
                              test_fixtures("test.jpg")
  end
end

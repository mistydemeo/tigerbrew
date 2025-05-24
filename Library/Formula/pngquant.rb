class Pngquant < Formula
  desc "PNG image optimizing utility"
  homepage "https://pngquant.org/"
  url "https://pngquant.org/pngquant-2.5.0-src.tar.bz2"
  sha256 "83c941f9fc7d4d6a566ca1243bff38fc9c46e4c74b6dc352fb5eac68b2297839"
  head "https://github.com/pornel/pngquant.git"


  depends_on "pkg-config" => :build
  depends_on "libpng"
  depends_on "little-cms2" => :optional

  option "with-openmp", "Enable OpenMP"
  needs :openmp if build.with? "openmp"

  def install
    ENV.append_to_cflags "-DNDEBUG" # Turn off debug

    args = ["--prefix=#{prefix}"]
    args << "--with-lcms2" if build.with? "little-cms2"

    if build.with? "openmp"
      args << "--with-openmp"
      args << "--without-cocoa"
    end

    system "./configure", *args
    system "make", "install", "CC=#{ENV.cc}"

    man1.install "pngquant.1"
    lib.install "lib/libimagequant.a"
    include.install "lib/libimagequant.h"
  end

  test do
    system "#{bin}/pngquant", test_fixtures("test.png"), "-o", "out.png"
    File.exist? testpath/"out.png"
  end
end

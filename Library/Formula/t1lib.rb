class T1lib < Formula
  desc "C library to generate/rasterize bitmaps from Type 1 fonts"
  homepage "http://www.t1lib.org/"
  url "http://www.ibiblio.org/pub/Linux/libs/graphics/t1lib-5.1.2.tar.gz"
  sha256 "821328b5054f7890a0d0cd2f52825270705df3641dbd476d58d17e56ed957b59"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "without_doc"
    system "make", "install"
    share.install "Fonts" => "fonts"
  end
end

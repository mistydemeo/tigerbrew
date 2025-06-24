class Imlib2 < Formula
  desc "Image loading and rendering library"
  homepage "http://sourceforge.net/projects/enlightenment/files/"
  url "https://downloads.sourceforge.net/project/enlightenment/imlib2-src/1.4.7/imlib2-1.4.7.tar.bz2"
  sha256 "35d733ce23ad7d338cff009095d37e656cb8a7a53717d53793a38320f9924701"
  revision 2


  deprecated_option "without-x" => "without-x11"

  depends_on "freetype"
  depends_on "libpng" => :recommended
  depends_on :x11 => :recommended
  depends_on "pkg-config" => :build
  depends_on "jpeg" => :recommended

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-amd64=no
    ]
    args << "--without-x" if build.without? "x11"

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{bin}/imlib2_conv", test_fixtures("test.png"), "imlib2_test.png"
  end
end

class Webp < Formula
  desc "Image format providing lossless and lossy compression for web images"
  homepage "https://developers.google.com/speed/webp/"
  url "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.6.0.tar.gz"
  sha256 "e4ab7009bf0629fd11982d4c2aa83964cf244cffba7347ecd39019a9e38c4564"
  license "BSD-3-Clause"

  bottle do
  end

  head do
    url "https://chromium.googlesource.com/webm/libwebp.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  depends_on "giflib"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"

  def install
    system "./autogen.sh" if build.head?

    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--enable-libwebpmux",
                          "--enable-libwebpdemux",
                          "--enable-libwebpdecoder",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/cwebp", test_fixtures("test.png"), "-o", "webp_test.png"
    system "#{bin}/dwebp", "webp_test.png", "-o", "webp_test.webp"
    assert File.exist?("webp_test.webp")
  end
end

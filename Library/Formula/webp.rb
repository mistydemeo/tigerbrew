require 'formula'

class Webp < Formula
  homepage 'http://code.google.com/speed/webp/'
  url 'https://webp.googlecode.com/files/libwebp-0.4.0.tar.gz'
  sha1 '326c4b6787a01e5e32a9b30bae76442d18d2d1b6'
  head 'https://chromium.googlesource.com/webm/libwebp', :branch => 'master'

  bottle do
    cellar :any
    sha1 "cfc09a4de229056b8b29fc010a9faf3d1dddd78b" => :tiger_g3
    sha1 "61120184fc380a47a8a44fdff85218690595d01c" => :tiger_altivec
    sha1 "4194ad065f197bb3ef284fc101c45bc032799b42" => :leopard_g3
    sha1 "1ab5a2d65ceefc4e2b29319801271d0d34895f97" => :leopard_altivec
  end

  revision 1

  option :universal

  depends_on 'libpng'
  depends_on 'jpeg' => :recommended
  depends_on 'libtiff' => :optional
  depends_on 'giflib' => :optional

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--enable-libwebpmux",
                          "--enable-libwebpdemux",
                          "--enable-libwebpdecoder",
                          "--prefix=#{prefix}"
    system "make install"
  end

  test do
    system "#{bin}/cwebp", test_fixtures("test.png"), "-o", "webp_test.png"
    system "#{bin}/dwebp", "webp_test.png", "-o", "webp_test.webp"
  end
end

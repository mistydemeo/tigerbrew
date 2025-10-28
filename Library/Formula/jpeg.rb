class Jpeg < Formula
  desc "JPEG image manipulation library"
  homepage "http://www.ijg.org"
  url "http://www.ijg.org/files/jpegsrc.v9f.tar.gz"
  sha256 "04705c110cb2469caa79fb71fba3d7bf834914706e9641a4589485c1f832565b"

  bottle do
    cellar :any
    sha256 "5790906a1aeb4a3610ee3b1fdb9f04dd597b8964869e5cdca8f034f9fb3cffd4" => :tiger_altivec
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/djpeg", test_fixtures("test.jpg")
  end
end

class SLang < Formula
  desc "Library for creating multi-platform software"
  homepage "http://www.jedsoft.org/slang/"
  url "http://www.jedsoft.org/releases/slang/slang-2.3.3.tar.bz2"
  sha256 "f9145054ae131973c61208ea82486d5dd10e3c5cdad23b7c4a0617743c8f5a18"

  bottle do
    sha256 "2cc2cc6f075322895ca0c101e2d37d3c401984c2026ef1ab066fb2a6a379c9e2" => :tiger_altivec
  end

  depends_on "libpng"
  depends_on "pcre" => :optional
  depends_on "oniguruma" => :optional
  depends_on "zlib"

  def install
    png = Formula["libpng"]
    system "./configure", "--prefix=#{prefix}",
                          "--with-pnglib=#{png.lib}",
                          "--with-pnginc=#{png.include}",
                          "--with-z=#{Formula["zlib"].opt_prefix}"
    ENV.j1
    system "make"
    system "make", "install"
  end

  test do
    assert_equal "Hello World!", shell_output("#{bin}/slsh -e 'message(\"Hello World!\");'").strip
  end
end

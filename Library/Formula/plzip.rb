class Plzip < Formula
  desc "Data compressor"
  homepage "http://www.nongnu.org/lzip/plzip.html"
  url "http://download.savannah.gnu.org/releases/lzip/plzip/plzip-1.4.tar.gz"
  sha256 "2a152ee429495cb96c22a51b618d1d19882db3e24aff79329d9c755a2a2f67bb"


  depends_on "lzlib"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "CXX=#{ENV.cxx}",
                          "CXXFLAGS=#{ENV.cflags}"
    system "make"
    system "make", "check"
    system "make", "-j1", "install"
  end

  test do
    text = "Hello Homebrew!"
    compressed = pipe_output("#{bin}/plzip -c", text)
    assert_equal text, pipe_output("#{bin}/plzip -d", compressed)
  end
end

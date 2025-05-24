class Jpegoptim < Formula
  desc "Utility to optimize JPEG files"
  homepage "https://github.com/tjko/jpegoptim"
  url "https://github.com/tjko/jpegoptim/archive/RELEASE.1.4.3.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/j/jpegoptim/jpegoptim_1.4.3.orig.tar.gz"
  sha256 "f892f5917c8dd8259d319df204e4bc13806b90389041ca7a4a24d8a5c25c7013"
  head "https://github.com/tjko/jpegoptim.git"
  revision 1


  depends_on "jpeg"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    ENV.j1 # Install is not parallel-safe
    system "make", "install"
  end

  test do
    source = test_fixtures("test.jpg")
    assert_match(/OK/, shell_output("#{bin}/jpegoptim --noaction #{source}"))
  end
end

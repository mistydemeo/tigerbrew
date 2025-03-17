class Lzip < Formula
  desc "LZMA-based compression program similar to gzip or bzip2"
  homepage "http://www.nongnu.org/lzip/lzip.html"
  url "http://download.savannah.gnu.org/releases/lzip/lzip-1.25.tar.gz"
  sha256 "09418a6d8fb83f5113f5bd856e09703df5d37bae0308c668d0f346e3d3f0a56f"
  license "GPL-2.0-or-later"

  bottle do
    cellar :any_skip_relocation
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "CXX=#{ENV.cxx}",
                          "CXXFLAGS=#{ENV.cflags}"
    system "make", "check"
    ENV.j1
    system "make", "install"
  end

  test do
    path = testpath/"data.txt"
    original_contents = "." * 1000
    path.write original_contents

    # compress: data.txt -> data.txt.lz
    system "#{bin}/lzip", path
    assert !path.exist?

    # decompress: data.txt.lz -> data.txt
    system "#{bin}/lzip", "-d", "#{path}.lz"
    assert_equal original_contents, path.read
  end
end

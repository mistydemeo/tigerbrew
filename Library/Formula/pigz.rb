class Pigz < Formula
  desc "Parallel gzip"
  homepage "http://www.zlib.net/pigz/"
  url "http://www.zlib.net/pigz/pigz-2.3.3.tar.gz"
  sha256 "4e8b67b432ce7907575a549f3e1cac4709781ba0f6b48afea9f59369846b509c"


  def install
    system "make", "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags}"
    bin.install "pigz", "unpigz"
    man1.install "pigz.1"
    man1.install_symlink "pigz.1" => "unpigz.1"
  end

  test do
    test_data = "a" * 1000
    (testpath/"example").write test_data
    system bin/"pigz", testpath/"example"
    assert (testpath/"example.gz").file?
    system bin/"unpigz", testpath/"example.gz"
    assert_equal test_data, (testpath/"example").read
  end
end

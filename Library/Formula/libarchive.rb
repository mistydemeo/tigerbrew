class Libarchive < Formula
  desc "Multi-format archive and compression library"
  homepage "http://www.libarchive.org"
  url "http://www.libarchive.org/downloads/libarchive-3.8.4.tar.gz"
  mirror "https://github.com/libarchive/libarchive/releases/download/v3.8.4/libarchive-3.8.4.tar.gz"
  sha256 "b2c75b132a0ec43274d2867221befcb425034cd038e465afbfad09911abb1abb"
  license "BSD-2-Clause"

  bottle do
    cellar :any
  end

  depends_on "bzip2"
  depends_on "lz4"
  depends_on "xz"
  depends_on "zlib"

  keg_only :provided_by_osx

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--without-lzo2",
                          "--without-nettle",
                          "--without-xml2",
                          "--without-expat"
    system "make", "install"
  end

  test do
    (testpath/"test").write("test")
    system bin/"bsdtar", "-czvf", "test.tar.gz", "test"
    assert_match /test/, shell_output("#{bin}/bsdtar -xOzf test.tar.gz")
  end
end

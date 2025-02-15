class Libarchive < Formula
  desc "Multi-format archive and compression library"
  homepage "http://www.libarchive.org"
  url "http://www.libarchive.org/downloads/libarchive-3.7.7.tar.gz"
  sha256 "4cc540a3e9a1eebdefa1045d2e4184831100667e6d7d5b315bb1cbc951f8ddff"
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

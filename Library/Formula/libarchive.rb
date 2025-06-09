class Libarchive < Formula
  desc "Multi-format archive and compression library"
  homepage "https://www.libarchive.org"
  url "http://www.libarchive.org/downloads/libarchive-3.7.9.tar.gz"
  mirror "https://github.com/libarchive/libarchive/releases/download/v3.7.9/libarchive-3.7.9.tar.gz"
  sha256 "aa90732c5a6bdda52fda2ad468ac98d75be981c15dde263d7b5cf6af66fd009f"
  license "BSD-2-Clause"

  bottle do
    cellar :any
    sha256 "c828da21bc11f7879c6de14459e7acf12c79e7cdbfc599fa014af0a564ffb8b5" => :tiger_altivec
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

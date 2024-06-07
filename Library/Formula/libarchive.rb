class Libarchive < Formula
  desc "Multi-format archive and compression library"
  homepage "http://www.libarchive.org"
  url "http://www.libarchive.org/downloads/libarchive-3.7.4.tar.gz"
  sha256 "7875d49596286055b52439ed42f044bd8ad426aa4cc5aabd96bfe7abb971d5e8"

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
                          "--without-expat",
                          "ac_cv_header_sys_queue_h=no" # Use the up to date copy provided to obtain STAILQ_FOREACH
    system "make", "install"
  end

  test do
    (testpath/"test").write("test")
    system bin/"bsdtar", "-czvf", "test.tar.gz", "test"
    assert_match /test/, shell_output("#{bin}/bsdtar -xOzf test.tar.gz")
  end
end

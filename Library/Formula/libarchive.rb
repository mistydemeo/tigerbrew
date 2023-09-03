class Libarchive < Formula
  desc "Multi-format archive and compression library"
  homepage "http://www.libarchive.org"
  url "http://www.libarchive.org/downloads/libarchive-3.6.2.tar.gz"
  sha256 "ba6d02f15ba04aba9c23fd5f236bb234eab9d5209e95d1c4df85c44d5f19b9b3"

  bottle do
    cellar :any
    sha256 "87223352a31f02ebd1a860c61659048ea457b2e665d5e90271782849ecca5df9" => :tiger_altivec
  end

  depends_on "xz" => :optional

  keg_only :provided_by_osx

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--without-lzo2",
                          "--without-nettle",
                          "--without-xml2"
    system "make", "install"
  end

  test do
    (testpath/"test").write("test")
    system bin/"bsdtar", "-czvf", "test.tar.gz", "test"
    assert_match /test/, shell_output("#{bin}/bsdtar -xOzf test.tar.gz")
  end
end

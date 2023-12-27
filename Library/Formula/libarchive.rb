class Libarchive < Formula
  desc "Multi-format archive and compression library"
  homepage "http://www.libarchive.org"
  url "http://www.libarchive.org/downloads/libarchive-3.6.2.tar.gz"
  sha256 "ba6d02f15ba04aba9c23fd5f236bb234eab9d5209e95d1c4df85c44d5f19b9b3"
  revision 1

  bottle do
    cellar :any
    sha256 "5813acc104cd5b3e718b7554b2cd5e46dd320b845b01ba92e669df8979caf767" => :tiger_altivec
  end

  depends_on "xz" => :optional

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

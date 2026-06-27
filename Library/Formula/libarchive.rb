class Libarchive < Formula
  desc "Multi-format archive and compression library"
  homepage "http://www.libarchive.org"
  url "http://www.libarchive.org/downloads/libarchive-3.8.8.tar.gz"
  mirror "https://github.com/libarchive/libarchive/releases/download/v3.8.8/libarchive-3.8.8.tar.gz"
  sha256 "038918ea315cdd446cc63acfe880d6011832bbe1711c887de5de5441b306c190"
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
    # GCC 4.2 blows up with any optimisation enabled.
    # libarchive/archive_write_set_format_pax.c: In function ‘archive_write_pax_header’:
    # libarchive/archive_write_set_format_pax.c:580: internal compiler error: Bus error
    # https://github.com/libarchive/libarchive/issues/3189
    ENV.O0 if ENV.compiler == :gcc
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

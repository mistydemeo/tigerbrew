class Libextractor < Formula
  desc "Library to extract meta data from files"
  homepage "https://www.gnu.org/software/libextractor/"
  url "http://ftpmirror.gnu.org/libextractor/libextractor-1.3.tar.gz"
  mirror "https://ftp.gnu.org/gnu/libextractor/libextractor-1.3.tar.gz"
  sha256 "868ad64c9a056d6b923d451d746935bffb1ddf5d89c3eb4f67d786001a3f7b7f"


  depends_on "pkg-config" => :build
  depends_on "libtool" => :run
  depends_on "iso-codes" => :optional

  def install
    ENV.deparallelize

    system "./configure", "--disable-silent-rules",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    fixture = test_fixtures("test.png")
    assert_match /Keywords for file/, shell_output("#{bin}/extract #{fixture}")
  end
end

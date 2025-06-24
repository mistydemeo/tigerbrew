class Lcab < Formula
  desc "Cabinet file creation tool"
  homepage "http://ohnopub.net/~ohnobinki/lcab/"
  url "ftp://mirror.ohnopub.net/mirror/lcab-1.0b12.tar.gz"
  mirror "https://launchpad.net/ubuntu/intrepid/+source/lcab/1.0b12-3/+files/lcab_1.0b12.orig.tar.gz"
  sha256 "065f2c1793b65f28471c0f71b7cf120a7064f28d1c44b07cabf49ec0e97f1fc8"


  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test").write "a test"

    system "#{bin}/lcab", "test", "test.cab"
    assert File.exist? "test.cab"
  end
end

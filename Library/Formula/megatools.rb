class Megatools < Formula
  desc "Command-line client for Mega.co.nz"
  homepage "http://megatools.megous.com/"
  url "http://megatools.megous.com/builds/megatools-1.9.95.tar.gz"
  sha256 "a46a560c8769b40f073fd27b321d6b89f8ac0f0ca73e6ed83047c2619fe6b437"


  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "glib-networking"
  depends_on "openssl"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # Downloads a publicly hosted file and verifies its contents.
    system "#{bin}/megadl",
      "https://mega.co.nz/#!3Q5CnDCb!PivMgZPyf6aFnCxJhgFLX1h9uUTy9ehoGrEcAkGZSaI",
      "--path", "testfile.txt"
    assert_equal File.read("testfile.txt"), "Hello Homebrew!\n"
  end
end

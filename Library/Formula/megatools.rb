class Megatools < Formula
  desc "Command-line client for Mega.co.nz"
  homepage "https://xff.cz/megatools/"
  url "http://megatools.megous.com/builds/megatools-1.9.95.tar.gz"
  sha256 "a46a560c8769b40f073fd27b321d6b89f8ac0f0ca73e6ed83047c2619fe6b437"

  bottle do
    cellar :any
    sha256 "0311e2291fada711351ae78aed4e1a07650f662546672e13d7e9c804dd331e29" => :yosemite
    sha256 "cfe36bb96c87610af7cf48d554d79639523976ceb9ca7dbd1c5676472b6075cb" => :mavericks
    sha256 "b9c56994907575b087c495495ff131d578809a2d1e1cb2199f8a135fe1dfb39c" => :mountain_lion
  end

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

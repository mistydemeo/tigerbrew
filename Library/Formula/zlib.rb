class Zlib < Formula
  desc "General-purpose lossless data-compression library"
  homepage "http://www.zlib.net/"
  url "https://zlib.net/fossils/zlib-1.3.1.tar.gz"
  sha256 "9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23"

  bottle do
    cellar :any
    sha256 "0ec484b96d45d53be8501f85f4b81b2ac2d70d84fd5d1602ece4668d570b05af" => :tiger_altivec
  end

  option :universal

  keg_only :provided_by_osx

  # http://zlib.net/zlib_how.html
  resource "test_artifact" do
    url "http://zlib.net/zpipe.c"
    version "20051211"
    sha256 "68140a82582ede938159630bca0fb13a93b4bf1cb2e85b08943c26242cf8f3a6"
  end

  def install
    ENV.universal_binary if build.universal?

    # The test in configure to see if shared library support is available
    # is done so by invoking gcc -w and then falls back to building just a
    # static library.
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    testpath.install resource("test_artifact")
    system ENV.cc, "zpipe.c", "-I#{include}", "-L#{lib}", "-lz", "-o", "zpipe"

    touch "foo.txt"
    output = "./zpipe < foo.txt > foo.txt.z"
    system output
    assert File.exist?("foo.txt.z")
  end
end

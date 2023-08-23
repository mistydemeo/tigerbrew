class Zlib < Formula
  desc "General-purpose lossless data-compression library"
  homepage "http://www.zlib.net/"
  url "http://zlib.net/fossils/zlib-1.2.13.tar.gz"
  sha256 "b3a24de97a8fdbc835b9833169501030b8977031bcb54b3b3ac13740f846ab30"

  bottle do
    cellar :any
    sha256 "1df174f616cf57e45253bd97fdca4ec850633fd99135f617fae648290cd1bb8d" => :tiger_g4
    sha256 "fa7db0585632ca457ac920ca49facc23aafbe36668dac4b073b51e926bcfd53a" => :tiger_g4e
    sha256 "66150f97576a183f6c1fd2edf37be055fa8a71b47c6286369a0ad0c6b64a1056" => :tiger_g5
  end

  keg_only :provided_by_osx

  # http://zlib.net/zlib_how.html
  resource "test_artifact" do
    url "http://zlib.net/zpipe.c"
    version "20051211"
    sha256 "68140a82582ede938159630bca0fb13a93b4bf1cb2e85b08943c26242cf8f3a6"
  end

  def install
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

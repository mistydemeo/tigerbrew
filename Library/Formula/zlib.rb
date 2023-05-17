class Zlib < Formula
  desc "General-purpose lossless data-compression library"
  homepage "http://www.zlib.net/"
  url "http://zlib.net/zlib-1.2.13.tar.gz"
  sha256 "b3a24de97a8fdbc835b9833169501030b8977031bcb54b3b3ac13740f846ab30"

  bottle do
    cellar :any
    sha256 "6765c51c09a7aa0ad7c06379a9c7a6b7b3b1bfaaf6a37d111cee44153eaab6e2" => :sierra
    sha256 "c37af2435a876fed3d8ced49698159ac7ab05efeed265de3c40a8e6c3868e332" => :el_capitan
    sha256 "1c3d8a42f15b8f8f5427e5038c76538178b2b57759c57101fb07cbbe92d0ba21" => :yosemite
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
    # is done so by envoking gcc -w and then falls back to building just a
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

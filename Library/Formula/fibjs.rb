class Fibjs < Formula
  desc "JavaScript on Fiber"
  homepage "http://fibjs.org"
  url "https://github.com/xicilion/fibjs/releases/download/v0.1.6/fibjs-0.1.6-fullsrc.zip"
  sha256 "e942f2ace2699700920c0b58d53c0a8f567f83d6af1085cb4249fd77c40cf18c"

  head "https://github.com/xicilion/fibjs.git"


  depends_on "cmake" => :build

  def install
    system "./build", "Release", "-j#{ENV.make_jobs}"
    bin.install "bin/Darwin_Release/fibjs"
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = `#{bin}/fibjs #{path}`.strip
    assert_equal "hello", output
    assert_equal 0, $?.exitstatus
  end
end

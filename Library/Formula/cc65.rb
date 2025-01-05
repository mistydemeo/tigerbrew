class Cc65 < Formula
  desc "6502 C compiler"
  homepage "https://cc65.github.io/"
  url "https://github.com/cc65/cc65/archive/refs/tags/V2.19.tar.gz"
  sha256 "157b8051aed7f534e5093471e734e7a95e509c577324099c3c81324ed9d0de77"
  head "https://github.com/cc65/cc65.git"

  bottle do
    sha256 "f46036288e98583501e57c9665196b5c456dd4449d6f64bebbac8190d0fd443f" => :tiger_altivec
  end

  # impressively, Makefile causes ancient make to crash
  depends_on "make" => :build

  def install
    ENV.no_optimization
    system "gmake", "PREFIX=#{prefix}"
    system "gmake", "install", "PREFIX=#{prefix}"
  end

  def caveats; <<-EOS.undent
    Library files have been installed to:
      #{share}/cc65
    EOS
  end

  test do
    (testpath/"foo.c").write "int main (void) { return 0; }"

    system bin/"cl65", "foo.c" # compile and link
    assert File.exist?("foo")  # binary
  end
end

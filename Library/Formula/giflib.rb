class Giflib < Formula
  desc "GIF library using patented LZW algorithm"
  homepage "http://giflib.sourceforge.net/"
  url "https://prdownloads.sourceforge.net/project/giflib/giflib-5.2.2.tar.gz"
  sha256 "be7ffbd057cadebe2aa144542fd90c6838c6a083b5e8a9048b8ee3b66b29d5fb"

  bottle do
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    # Pass CFLAGS to explicitly override the CFLAGS from the makefile,
    # which contains some flags that are incompatible with GCC 4.0/4.2
    system "make", "all", "CFLAGS=#{ENV.cflags}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    output = shell_output("#{bin}/giftext #{test_fixtures("test.gif")}")
    assert_match "Screen Size - Width = 1, Height = 1", output
  end
end

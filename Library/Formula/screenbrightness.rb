class Screenbrightness < Formula
  desc "Change OS X display brightness from the command-line"
  homepage "https://github.com/nriley/brightness"
  url "https://github.com/nriley/brightness/archive/1.2.tar.gz"
  sha256 "6094c9f0d136f4afaa823d299f5ea6100061c1cec7730bf45c155fd98761f86b"


  def install
    system "make"
    system "make", "prefix=#{prefix}", "install"
  end

  test do
    system "#{bin}/brightness", "-l"
  end
end

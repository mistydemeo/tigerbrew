class Libtermkey < Formula
  desc "Library for processing keyboard entry from the terminal"
  homepage "http://www.leonerd.org.uk/code/libtermkey/"
  url "http://www.leonerd.org.uk/code/libtermkey/libtermkey-0.17.tar.gz"
  sha256 "68949364ed5eaad857b3dea10071cde74b00b9f236dfbb702169f246c3cef389"


  option :universal

  depends_on "pkg-config" => :build
  depends_on "libtool" => :build

  def install
    ENV.universal_binary if build.universal?

    system "make", "PREFIX=#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"
  end
end

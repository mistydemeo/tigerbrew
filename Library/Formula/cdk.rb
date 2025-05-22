class Cdk < Formula
  desc "Curses development kit provides predefined curses widget for apps"
  homepage "http://invisible-island.net/cdk/"
  url "ftp://invisible-island.net/cdk/cdk-5.0-20141106.tgz"
  version "5.0.20141106"
  sha256 "d7ce8d9698b4998fa49a63b6e19309d3eb61cc3a019bfc95101d845ef03c4803"


  def install
    system "./configure", "--prefix=#{prefix}", "--with-ncurses"
    system "make", "install"
  end

  test do
    assert_match "#{lib}", shell_output("#{bin}/cdk5-config --libdir")
  end
end

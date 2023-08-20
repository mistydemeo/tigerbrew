class Wakeonlan < Formula
  desc "Sends magic packets to wake up network-devices"
  homepage "https://github.com/jpoliv/wakeonlan"
  url "https://github.com/jpoliv/wakeonlan/archive/refs/tags/v0.42.tar.gz"
  sha256 "4f533f109f7f4294f6452b73227e2ce4d2aa81091cf6ae1f4fa2f87bad04a031"

  depends_on "perl"

  def install
    system "perl", "Makefile.PL"
    system "make"
    bin.install "blib/script/wakeonlan"
    man1.install "blib/man1/wakeonlan.1"
  end
end

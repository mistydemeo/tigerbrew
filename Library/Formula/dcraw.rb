class Dcraw < Formula
  desc "Digital camera RAW photo decoding software"
  homepage "https://www.cybercom.net/~dcoffin/dcraw/"
  url "https://mirror.pnl.gov/macports/distfiles/dcraw/dcraw-9.26.0.tar.gz"
  sha256 "85791d529e037ad5ca09770900ae975e2e4cc1587ca1da4192ca072cbbfafba3"
  revision 1


  depends_on "jpeg"
  depends_on "jasper"
  depends_on "little-cms2"

  def install
    ENV.append_to_cflags "-I#{HOMEBREW_PREFIX}/include -L#{HOMEBREW_PREFIX}/lib"
    system "#{ENV.cc} -o dcraw #{ENV.cflags} dcraw.c -lm -ljpeg -llcms2 -ljasper"
    bin.install "dcraw"
    man1.install "dcraw.1"
  end
end

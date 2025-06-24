class Ufraw < Formula
  desc "Unidentified Flying RAW: RAW image processing utility"
  homepage "http://ufraw.sourceforge.net"
  url "https://downloads.sourceforge.net/project/ufraw/ufraw/ufraw-0.22/ufraw-0.22.tar.gz"
  sha256 "f7abd28ce587db2a74b4c54149bd8a2523a7ddc09bedf4f923246ff0ae09a25e"
  revision 1


  depends_on "pkg-config" => :build
  depends_on "libpng"
  depends_on "dcraw"
  depends_on "glib"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "little-cms"
  depends_on "exiv2" => :optional

  fails_with :llvm do
    cause "Segfault while linking"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-gtk",
                          "--without-gimp"
    system "make", "install"
    (share+"pixmaps").rmtree
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ufraw-batch --version 2>&1")
  end
end

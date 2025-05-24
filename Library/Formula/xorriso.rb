class Xorriso < Formula
  desc "ISO9660+RR manipulation tool"
  homepage "https://www.gnu.org/software/xorriso/"
  url "http://ftpmirror.gnu.org/xorriso/xorriso-1.4.0.tar.gz"
  mirror "https://ftp.gnu.org/gnu/xorriso/xorriso-1.4.0.tar.gz"
  sha256 "0bd1e085015b28c24f57697d6def2fe84517967dc417554c0c3ccf1685ed0e56"


  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/xorriso", "--help"
  end
end

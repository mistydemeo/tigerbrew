class Libflowmanager < Formula
  desc "Flow-based measurement tasks with packet-based inputs"
  homepage "http://research.wand.net.nz/software/libflowmanager.php"
  url "http://research.wand.net.nz/software/libflowmanager/libflowmanager-2.0.4.tar.gz"
  sha256 "80fbb93113fab98727b42c9b96ea09c0d817a49f884717dd27f27325e93b733c"


  depends_on "libtrace"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

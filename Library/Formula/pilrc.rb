class Pilrc < Formula
  desc "PILot Resource Compiler for Palm OS"
  homepage "https://pilrc.sourceforge.net"
  url "https://downloads.sourceforge.net/project/pilrc/pilrc/3.2/pilrc-3.2.tar.gz"
  sha256 "f3d6ea3c77f5d2a00707f4372a212377ab7bd77b3d68c3db7e28a553b235903f"

  def install
    system "./unix/configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

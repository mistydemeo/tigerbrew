class Pilrc < Formula
  desc "PILot Resource Compiler for Palm OS"
  homepage "https://pilrc.sourceforge.net"
  url "https://downloads.sourceforge.net/project/pilrc/pilrc/3.2/pilrc-3.2.tar.gz"
  sha256 "f3d6ea3c77f5d2a00707f4372a212377ab7bd77b3d68c3db7e28a553b235903f"

  bottle do
    sha256 "eb934781d16929e8bb8b34629e79111a438612b810dc31094236ff02d688f61c" => :tiger_altivec
  end

  def install
    system "./unix/configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

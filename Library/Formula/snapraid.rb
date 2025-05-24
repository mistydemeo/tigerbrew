class Snapraid < Formula
  desc "Backup program for disk arrays"
  homepage "http://snapraid.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/snapraid/snapraid-8.1.tar.gz"
  sha256 "6bf89a1319ac3403958cd2c98a9c6102728c0070cfa1aedd90c4561d93c54e5d"

  head do
    url "https://github.com/amadvance/snapraid.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end


  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/snapraid --version")
  end
end

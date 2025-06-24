class Mikmod < Formula
  desc "Portable tracked music player"
  homepage "http://mikmod.raphnet.net/"
  url "https://downloads.sourceforge.net/project/mikmod/mikmod/3.2.6/mikmod-3.2.6.tar.gz"
  sha256 "04544e0edb36a19fab61233dff97430969cff378a98f5989a1378320550e2673"


  depends_on "libmikmod"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    system "#{bin}/mikmod", "-V"
  end
end

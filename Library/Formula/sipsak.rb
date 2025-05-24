class Sipsak < Formula
  desc "SIP Swiss army knife"
  homepage "https://sourceforge.net/projects/sipsak.berlios/"
  url "https://downloads.sourceforge.net/project/sipsak.berlios/sipsak-0.9.6-1.tar.gz"
  version "0.9.6"
  sha256 "5064c56d482a080b6a4aea71821b78c21b59d44f6d1aa14c27429441917911a9"


  depends_on "openssl"

  def install
    ENV.append "CFLAGS", "-std=gnu89"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    system "#{bin}/sipsak", "-V"
  end
end

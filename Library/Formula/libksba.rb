class Libksba < Formula
  desc "X.509 and CMS library"
  homepage "https://www.gnupg.org/related_software/libksba/index.en.html"
  url "https://www.gnupg.org/ftp/gcrypt/libksba/libksba-1.6.7.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libksba/libksba-1.6.7.tar.bz2"
  sha256 "cf72510b8ebb4eb6693eef765749d83677a03c79291a311040a5bfd79baab763"

  bottle do
  end

  depends_on "libgpg-error"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system "#{bin}/ksba-config", "--libs"
  end
end

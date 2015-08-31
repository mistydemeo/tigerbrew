class LibgpgError < Formula
  desc "Common error values for all GnuPG components"
  homepage "https://www.gnupg.org/"
  url "https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.20.tar.bz2"
  mirror "ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.20.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.20.tar.bz2"
  sha256 "3266895ce3419a7fb093e63e95e2ee3056c481a9bc0d6df694cfd26f74e72522"

  bottle do
    cellar :any
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system "#{bin}/gpg-error-config", "--libs"
  end
end

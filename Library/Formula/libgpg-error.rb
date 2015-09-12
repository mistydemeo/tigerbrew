class LibgpgError < Formula
  desc "Common error values for all GnuPG components"
  homepage "https://www.gnupg.org/"
  url "https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.20.tar.bz2"
  mirror "ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.20.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.20.tar.bz2"
  sha256 "3266895ce3419a7fb093e63e95e2ee3056c481a9bc0d6df694cfd26f74e72522"
  revision 1

  bottle do
    cellar :any
    sha256 "716a5ff0208092694e5d53ea379f85b3cdfbb4439b9b8d80a30039469c65e0cf" => :tiger_altivec
    sha256 "04d285ef2175eefc716abb6617e10e8f4e47bac36968ec0607607849e7a7222f" => :leopard_g3
    sha256 "09e37962ed965242557f5e430fcefe822e7af9cec6f240e6b16223b7d3fc7a64" => :leopard_altivec
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules",
                          "--enable-static"
    system "make", "install"
  end

  test do
    system "#{bin}/gpg-error-config", "--libs"
  end
end

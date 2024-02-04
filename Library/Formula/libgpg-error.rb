class LibgpgError < Formula
  desc "Common error values for all GnuPG components"
  homepage "https://www.gnupg.org/"
  url "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.47.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.47.tar.bz2"
  sha256 "9e3c670966b96ecc746c28c2c419541e3bcb787d1a73930f5e5f5e1bcbbb9bdb"

  bottle do
    sha256 "7c535ced4ccce90ce319aaf147b77f96e555d579c7448647aaccefa4afd21436" => :tiger_altivec
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version == :tiger
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules",
                          "--enable-static"
    system "make", "install"
  end

  test do
    system "#{bin}/gpgrt-config", "--libs"
  end
end

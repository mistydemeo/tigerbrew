class LibgpgError < Formula
  desc "Common error values for all GnuPG components"
  homepage "https://www.gnupg.org/"
  url "https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.51.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.51.tar.bz2"
  sha256 "be0f1b2db6b93eed55369cdf79f19f72750c8c7c39fc20b577e724545427e6b2"
  revision 1

  bottle do
    sha256 "ed1d0a4c74d6c32e89dc485803dffb9dd2e32ab783bd13f40aaaf6db216590a7" => :tiger_altivec
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    ENV.append_to_cflags "-D__DARWIN_UNIX03" if MacOS.version == :tiger
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules",
                          "--enable-install-gpg-error-config",
                          "--enable-static"
    system "make", "install"
  end

  test do
    system "#{bin}/gpgrt-config", "--libs"
  end
end

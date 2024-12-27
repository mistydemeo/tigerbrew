class LibgpgError < Formula
  desc "Common error values for all GnuPG components"
  homepage "https://www.gnupg.org/"
  url "https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.51.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.51.tar.bz2"
  sha256 "be0f1b2db6b93eed55369cdf79f19f72750c8c7c39fc20b577e724545427e6b2"

  bottle do
    sha256 "1afca6e0f2ebc686fbaeabaa0835d19a60b8a402c83080e9db9702b023223868" => :tiger_altivec
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

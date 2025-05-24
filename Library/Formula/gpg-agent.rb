class GpgAgent < Formula
  desc "GPG key agent"
  homepage "https://www.gnupg.org/"
  url "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.0.29.tar.bz2"
  mirror "ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.29.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.29.tar.bz2"
  sha256 "68ed6b386ba78425b05a60e8ee22785ff0fef190bdc6f1c612f19a58819d4ac9"


  depends_on "libgpg-error"
  depends_on "libgcrypt"
  depends_on "libksba"
  depends_on "libassuan"
  depends_on "pth"
  depends_on "pinentry"

  # Adjust package name to fit our scheme of packaging both
  # gnupg 1.x and 2.x, and gpg-agent separately
  patch :DATA

  def install
    # don't use Clang's internal stdint.h
    ENV["gl_cv_absolute_stdint_h"] = "#{MacOS.sdk_path}/usr/include/stdint.h"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-agent-only",
                          "--with-pinentry-pgm=#{Formula["pinentry"].opt_bin}/pinentry",
                          "--with-scdaemon-pgm=#{Formula["gnupg2"].opt_libexec}/scdaemon"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
      Remember to add "use-standard-socket" to your ~/.gnupg/gpg-agent.conf
      file.
    EOS
  end

  test do
    system "#{bin}/gpg-agent", "--help"
  end
end

__END__
diff --git a/configure b/configure
index c022805..96ea7ed 100755
--- a/configure
+++ b/configure
@@ -578,8 +578,8 @@ MFLAGS=
 MAKEFLAGS=

 # Identity of this package.
-PACKAGE_NAME='gnupg'
-PACKAGE_TARNAME='gnupg'
+PACKAGE_NAME='gpg-agent'
+PACKAGE_TARNAME='gpg-agent'
 PACKAGE_VERSION='2.0.29'
 PACKAGE_STRING='gnupg 2.0.29'
 PACKAGE_BUGREPORT='http://bugs.gnupg.org'

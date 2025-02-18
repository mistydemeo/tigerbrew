class Gnupg < Formula
  desc "GNU Pretty Good Privacy (PGP) package"
  homepage "https://www.gnupg.org/"
  url "ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.23.tar.bz2"
  mirror "https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-1.4.23.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.23.tar.bz2"
  sha256 "c9462f17e651b6507848c08c430c791287cd75491f8b5a8b50c6ed46b12678ba"
  revision 1

  bottle do
    sha256 "8d310b2e00d3dc8d9ba83eac61dc30b6908b4a11bceb2e3a15074ec94d9f3861" => :tiger_altivec
  end

  depends_on "curl" if MacOS.version <= :mavericks

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--program-suffix=1",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "check"

    # we need to create these directories because the install target has the
    # dependency order wrong
    [bin, libexec/"gnupg"].each(&:mkpath)
    system "make", "install"

    # https://lists.gnupg.org/pipermail/gnupg-devel/2016-August/031533.html
    inreplace bin/"gpg-zip1", "GPG=gpg", "GPG=gpg1"
  end

  def caveats; <<~EOS
    Tools from this formula are now installed with a 1 suffix,
    so gpg is now gpg1 for referring to GnuPG 1.4.x version.
    EOS
  end

  test do
    (testpath/"gen-key-script").write <<-EOS.undent
      Key-Type: RSA
      Key-Length: 4096
      Subkey-Type: RSA
      Subkey-Length: 4096
      Name-Real: Homebrew Test
      Name-Email: test@example.com
      Expire-Date: 0
    EOS
    system bin/"gpg1", "--batch", "--gen-key", "gen-key-script"
    (testpath/"test.txt").write ("Hello World!")
    system bin/"gpg1", "--armor", "--sign", "test.txt"
    system bin/"gpg1", "--verify", "test.txt.asc"
  end
end

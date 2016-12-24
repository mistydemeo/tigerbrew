class Libgcrypt < Formula
  desc "Cryptographic library based on the code from GnuPG"
  homepage "https://directory.fsf.org/wiki/Libgcrypt"
  url "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.7.3.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.7.3.tar.bz2"
  sha256 "ddac6111077d0a1612247587be238c5294dd0ee4d76dc7ba783cc55fb0337071"

  bottle do
    cellar :any
    sha256 "917d24c8069dc9ff48ba3cc0018b5a0740859e3dd6d344e48d00521572739f07" => :el_capitan
    sha256 "783f5e8ebce20aae53e576a5bb4068c67999168c90f4a66e765abc2d4c94a733" => :yosemite
    sha256 "b2d5c9c8d60afffa2983e952812ae46e566172b406806877f9675e907fc0db2e" => :mavericks
  end

  option :universal

  depends_on "libgpg-error"

  resource "config.h.ed" do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/ec8d133/libgcrypt/config.h.ed"
    version "113198"
    sha256 "d02340651b18090f3df9eed47a4d84bed703103131378e1e493c26d7d0c7aab1"
  end

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-asm",
                          "--with-libgpg-error-prefix=#{Formula["libgpg-error"].opt_prefix}"

    if build.universal?
      buildpath.install resource("config.h.ed")
      system "ed -s - config.h <config.h.ed"
    end

    # Parallel builds work, but only when run as separate steps
    system "make"
    system "make", "install"
    system "make", "check"

    # avoid triggering mandatory rebuilds of software that hard-codes this path
    inreplace bin/"libgcrypt-config", prefix, opt_prefix
  end

  test do
    touch "testing"
    output = shell_output("#{bin}/hmac256 \"testing\" testing")
    assert_match "0e824ce7c056c82ba63cc40cffa60d3195b5bb5feccc999a47724cc19211aef6", output
  end
end

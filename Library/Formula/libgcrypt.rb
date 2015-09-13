class Libgcrypt < Formula
  desc "Cryptographic library based on the code from GnuPG"
  homepage "https://gnupg.org/"
  url "https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.6.4.tar.bz2"
  mirror "ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.4.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.4.tar.bz2"
  sha256 "c9bc2c7fe2e5f4ea13b0c74f9d24bcbb1ad889bb39297d8082aebf23f4336026"

  bottle do
    cellar :any
    sha256 "f5f8bdd56ffa372a387a4a9c7364a422a1332ccfc1bab127bd090f8c426a33d6" => :tiger_altivec
    sha256 "43c4ee60bc2492569be5b40854f91859f1b5bee47c07768e39c4c15f5da06ea8" => :leopard_g3
    sha256 "31fe08073c55a9ca64e645baa8dbdae9c93e494b96864b1e414c64b3b7eefc12" => :leopard_altivec
  end

  option :universal

  depends_on "libgpg-error"

  resource "config.h.ed" do
    url "https://raw.githubusercontent.com/DomT4/scripts/4d0517f86/Homebrew_Resources/MacPorts_Import/libgcrypt/r113198/config.h.ed"
    mirror "https://trac.macports.org/export/113198/trunk/dports/devel/libgcrypt/files/config.h.ed"
    version "113198"
    sha256 "d02340651b18090f3df9eed47a4d84bed703103131378e1e493c26d7d0c7aab1"
  end

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-asm",
                          "--with-gpg-error-prefix=#{Formula["libgpg-error"].opt_prefix}"

    if build.universal?
      buildpath.install resource("config.h.ed")
      system "ed -s - config.h <config.h.ed"
    end

    # Parallel builds work, but only when run as separate steps
    system "make"
    system "make", "install"
    # Make check currently dies on El Capitan
    # https://github.com/Homebrew/homebrew/issues/41599
    # https://bugs.gnupg.org/gnupg/issue2056
    # This check should be above make install again when fixed.
    system "make", "check"
  end

  test do
    touch "testing"
    output = shell_output("#{bin}/hmac256 \"testing\" testing")
    assert_match /0e824ce7c056c82ba63cc40cffa60d3195b5bb5feccc999a47724cc19211aef6/, output
  end
end

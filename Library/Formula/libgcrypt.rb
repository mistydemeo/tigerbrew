class Libgcrypt < Formula
  desc "Cryptographic library based on the code from GnuPG"
  homepage "https://gnupg.org/"
  url "https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.6.3.tar.bz2"
  mirror "ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.3.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.3.tar.bz2"
  sha256 "41b4917b93ae34c6a0e2127378d7a4d66d805a2a86a09911d4f9bd871db7025f"
  revision 2

  bottle do
    cellar :any
    sha256 "967c3b4f8e69ff608cf6c6e318ff8632ddede4b99fade5e078ea06f6a7d8a577" => :tiger_altivec
    sha256 "02145c811e42c22911092789be5349876e555936d149dce0499b6136405b041f" => :leopard_g3
    sha256 "ea17238ee44f50e56a2bfa1647e34b0c88ef4ab59df100b02b7a65bff8fe502d" => :leopard_altivec
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
    # Make check currently dies on El Capitan
    # https://github.com/Homebrew/homebrew/issues/41599
    # https://bugs.gnupg.org/gnupg/issue2056
    system "make", "check" unless MacOS.version >= :el_capitan
    system "make", "install"
  end

  test do
    system bin/"libgcrypt-config", "--libs"
  end
end

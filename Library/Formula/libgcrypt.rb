class Libgcrypt < Formula
  desc "Cryptographic library based on the code from GnuPG"
  homepage "https://gnupg.org/"
  url "ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.3.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.3.tar.bz2"
  mirror "http://ftp.heanet.ie/mirrors/ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.3.tar.bz2"
  sha256 "41b4917b93ae34c6a0e2127378d7a4d66d805a2a86a09911d4f9bd871db7025f"
  revision 1

  bottle do
    cellar :any
    sha256 "d382f3bb291e5af1c0208a6d241e163771e0113ecae9b98e0d1c0f291cd217a6" => :tiger_altivec
    sha256 "d46eb34535b2e50245d55a31bd21041843ddbb64ab6efbd4d4875064d7702c65" => :leopard_g3
    sha256 "905acd394a18a172207587dc6379f6e2b0f439b68cc0c3ff40d775609a192" => :leopard_altivec
  end

  option :universal

  depends_on "libgpg-error"

  resource "config.h.ed" do
    url "https://trac.macports.org/export/113198/trunk/dports/devel/libgcrypt/files/config.h.ed"
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

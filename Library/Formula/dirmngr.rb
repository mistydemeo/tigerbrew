class Dirmngr < Formula
  desc "Server for managing certificate revocation lists"
  homepage "https://www.gnupg.org"
  url "ftp://ftp.gnupg.org/gcrypt/dirmngr/dirmngr-1.1.1.tar.bz2"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/d/dirmngr/dirmngr_1.1.1.orig.tar.bz2"
  sha256 "d2280b8c314db80cdaf101211a47826734443436f5c3545cc1b614c50eaae6ff"
  revision 1


  depends_on "libassuan"
  depends_on "libgpg-error"
  depends_on "libgcrypt"
  depends_on "libksba"
  depends_on "pth"

  patch :p0 do
    # patch by upstream developer to fix an API incompatibility with libgcrypt >=1.6.0
    # causing immediate segfault in dirmngr. see http://bugs.g10code.com/gnupg/issue1590
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/6965aa5/dirmngr/D186.diff"
    sha256 "0efbcf1e44177b3546fe318761c3386a11310a01c58a170ef60df366e5160beb"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"
    system "make"
    system "make", "install"
  end

  test do
    system "dirmngr-client", "--help"
    system "dirmngr", "--help"
  end
end

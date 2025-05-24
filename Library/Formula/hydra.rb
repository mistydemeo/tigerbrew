class Hydra < Formula
  desc "Network logon cracker which supports many services"
  homepage "https://www.thc.org/thc-hydra/"
  url "https://www.thc.org/releases/hydra-8.1.tar.gz"
  sha256 "e4bc2fd11f97a8d985a38a31785c86d38cc60383e47a8f4a5c436351e5135f19"

  head "https://github.com/vanhauser-thc/thc-hydra.git"


  depends_on "pkg-config" => :build
  depends_on :mysql
  depends_on "openssl"
  depends_on "subversion" => :optional
  depends_on "libidn" => :optional
  depends_on "libssh" => :optional
  depends_on "pcre" => :optional
  depends_on "gtk+" => :optional

  def install
    # Having our gcc in the PATH first can cause issues. Monitor this.
    # https://github.com/vanhauser-thc/thc-hydra/issues/22
    system "./configure", "--prefix=#{prefix}"
    bin.mkpath
    system "make", "all", "install"
    share.install prefix/"man" # Put man pages in correct place
  end
end

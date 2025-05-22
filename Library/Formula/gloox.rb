class Gloox < Formula
  desc "C++ Jabber/XMPP library that handles the low-level protocol"
  homepage "https://camaya.net/gloox/"
  url "https://camaya.net/download/gloox-1.0.12.tar.bz2"
  mirror "https://mirrors.kernel.org/debian/pool/main/g/gloox/gloox_1.0.12.orig.tar.bz2"
  sha256 "67125a2e98a9803179af75f1c9c3c0a14f0bc238d48f23c4a3cf7c8fdebc43a9"


  depends_on "pkg-config" => :build
  depends_on "openssl" => :recommended
  depends_on "gnutls" => :optional
  depends_on "libidn" => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      --with-zlib
      --disable-debug
    ]

    if build.with? "gnutls"
      args << "--with-gnutls=yes"
    else
      args << "--with-openssl=#{Formula["openssl"].opt_prefix}"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    system bin/"gloox-config", "--cflags", "--libs", "--version"
  end
end

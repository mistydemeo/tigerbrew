class TelepathyGabble < Formula
  desc "Telepathy Jabber/XMPP connection manager"
  homepage "http://telepathy.freedesktop.org/wiki/Components/"
  url "http://telepathy.freedesktop.org/releases/telepathy-gabble/telepathy-gabble-0.18.3.tar.gz"
  sha256 "8ec714607e9bcb8d5a3f44adf871e7b07d5db8e326e47536e74e09cba59989c2"
  revision 1


  depends_on "pkg-config" => :build
  depends_on "sqlite"
  depends_on "telepathy-glib"
  depends_on "openssl"
  depends_on "libsoup"
  depends_on "libnice"

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-tests
      --disable-gtk-doc-html
      --disable-static
      --disable-dependency-tracking
      --with-tls=openssl
      --with-ca-certificates=#{etc}/openssl/cert.pem
    ]

    system "./configure", *args
    system "make", "install"
  end
end

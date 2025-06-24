class Ucommon < Formula
  desc "GNU C++ runtime library for threads, sockets, and parsing"
  homepage "https://www.gnu.org/software/commoncpp/"
  url "http://ftpmirror.gnu.org/commonc++/ucommon-6.2.2.tar.gz"
  sha256 "1ddcef26dc5c930225de6ab9adc3c389cb3f585eba0b0f164206f89d2dafea66"


  depends_on "pkg-config" => :build
  depends_on "gnutls"

  def install
    # Replace the ldd with OS X's otool. This is unlikely to be merged upstream.
    # Emailed upstream (dyfet at gnu dot org) querying this on 25/11/14.
    # It generates a very minor runtime error without the inreplace, so...
    inreplace "commoncpp-config.in", "ldd /bin/sh", "otool -L /bin/sh"
    inreplace "ucommon-config.in", "ldd /bin/sh", "otool -L /bin/sh"

    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking",
                          "--disable-silent-rules", "--enable-socks",
                          "--with-sslstack=gnutls", "--with-pkg-config"
    system "make", "install"
  end

  test do
    system "#{bin}/ucommon-config", "--libs"
  end
end

class Alpine < Formula
  desc "News and email agent"
  homepage "http://alpine.freeiz.com/alpine/"
  url "http://alpine.freeiz.com/alpine/release/src/alpine-2.20.tar.xz"
  sha256 "ed639b6e5bb97e6b0645c85262ca6a784316195d461ce8d8411999bf80449227"


  depends_on "openssl"

  def install
    ENV.j1
    system "./configure", "--disable-debug",
                          "--with-ssl-dir=#{Formula["openssl"].opt_prefix}",
                          "--with-ssl-certs-dir=#{etc}/openssl",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/alpine", "-supported"
  end
end

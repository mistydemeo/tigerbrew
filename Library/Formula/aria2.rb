class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0.tar.xz"
  sha256 "58d1e7608c12404f0229a3d9a4953d0d00c18040504498b483305bcb3de907a5"

  depends_on "pkg-config" => :build
  # AppleTLS (what aria2 calls Security.framework's SecureTransport) doesn't work on OS X <= 10.5, so we can't use it on those OS X versions.
  # aria2 prefers GnuTLS over OpenSSL, but GnuTLS can sometimes cause the aria2c process to hang until SIGKILL'd on OS X <= 10.5, so we're using OpenSSL instead.
  depends_on "openssl" if MacOS.version < :snow_leopard
  # aria2 prefers libxml2 over expat, but for some reason, Tigerbrewed libxml2 (as well as libssh2 and sqlite) currently fails to be detected by aria2's configure for a yet-to-be-determined reason.
  # As a result, we are falling back to expat for the time being to provide aria2 XML functionality.
  depends_on "expat"

  needs :cxx11

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --without-gnutls
      --without-libgmp
      --without-libnettle
      --without-libgcrypt
    ]

    if MacOS.version < :snow_leopard
      args << "--with-openssl"
      args << "--without-appletls"
    else
      args << "--without-openssl"
      args << "--with-appletls"
    end

    system "./configure", *args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system "#{bin}/aria2c", "https://brew.sh/"
    assert_predicate testpath/"index.html", :exist?, "Failed to download https://brew.sh/index.html!"
  end
end

class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "http://aria2.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/aria2/stable/aria2-1.18.9/aria2-1.18.9.tar.bz2"
  sha1 "31ac90d9ffcdba4cdf936ddfbc3d8f08416360e6"

  bottle do
    cellar :any
    sha256 "45d7d73c781be08f658dbdd4ead963646863963711bbc28a27c1ef2db9f8bff" => :leopard_g3
    sha256 "17ee167e2c1b01b8b1e3ab0ce7914ca88b10a3e457647e2ef1417d24574b085f" => :leopard_altivec
  end

  # configure can't get C++11 working with new GCC on Tiger
  # TODO figure this out
  depends_on :macos => :leopard
  depends_on "pkg-config" => :build
  # Apple TLS doesn't work on Leopard
  depends_on "gnutls" if MacOS.version < :snow_leopard

  needs :cxx11

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --without-openssl
      --without-libgmp
      --without-libnettle
      --without-libgcrypt
    ]

    if MacOS.version < :snow_leopard
      args << "--with-gnutls" << "--without-appletls"
    else
      args << "--without-gnutls" << "--with-appletls"
    end

    system "./configure", *args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system "#{bin}/aria2c", "http://brew.sh"
    assert File.exist? "index.html"
  end
end

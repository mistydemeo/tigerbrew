class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "http://aria2.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/aria2/stable/aria2-1.19.0/aria2-1.19.0.tar.bz2"
  mirror "https://mirrors.kernel.org/debian/pool/main/a/aria2/aria2_1.19.0.orig.tar.bz2"
  sha256 "ae2b6fce7a0974c9156415cccf2395cd258580ab34eec2b34a8e76120b7240ce"

  bottle do
    cellar :any_skip_relocation
    sha256 "eb19d43e1bb8c6b44505881d8f49943ca781a8bf04c558d0916dcbcdd4a0fc8e" => :leopard_g3
    sha256 "1a0e3c43309c5a3cbfa294b983e29a2db3e1e5ac6ab17dca27dd1c1bfc5929cf" => :leopard_altivec
  end

  # configure can't get C++11 working with new GCC on Tiger
  # TODO figure this out
  depends_on :macos => :leopard
  depends_on "pkg-config" => :build
  # Apple TLS doesn't work on Leopard
  depends_on "gnutls" if MacOS.version < :snow_leopard

  needs :cxx11

  def install
    if MacOS.version > :tiger
      # Specifying -std=c++11 (which is what ENV.cxx11 does) on 10.4.x with gcc-7 causes the build to fail.
      # For some reason, omitting this flag allows aria2 to successfully build and run on OS X 10.4.x.
      # TODO: Verify if this behaviour occurs with other versions of GCC that support C++11 (such as gcc-6 or gcc-5).
      ENV.cxx11
    end

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

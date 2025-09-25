class Links < Formula
  desc "Lynx-like WWW browser that supports tables, menus, etc."
  homepage "http://links.twibright.com/"
  url "http://links.twibright.com/download/links-2.30.tar.bz2"
  sha256 "c4631c6b5a11527cdc3cb7872fc23b7f2b25c2b021d596be410dadb40315f166"
  license "GPL-2.0-or-later" => { with: "openvpn-openssl-exception" }

  bottle do
    cellar :any
  end

  depends_on "pkg-config" => :build
  depends_on :x11 => :recommended
  depends_on "bzip2"
  depends_on "openssl3" => :recommended
  depends_on "libressl" => :optional
  depends_on "libevent" if MacOS.version >= :snow_leopard
  depends_on "libpng" if build.with? "x11"
  depends_on "libtiff" if build.with? "x11"
  depends_on "jpeg" if build.with? "x11"
  depends_on "webp" if build.with? "x11"
  depends_on "librsvg" => :optional
  depends_on "zlib"

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --mandir=#{man}
    ]

    if build.with? "libressl"
      args << "--with-ssl=#{Formula["libressl"].opt_prefix}"
    else
      args << "--with-ssl=#{Formula["openssl3"].opt_prefix}"
    end

    args << "--enable-graphics" if build.with? "x11"
    args << "--without-libtiff" if build.without? "x11"
    args << "--without-libjpeg" if build.without? "x11"
    args << "--without-librsvg" if build.without? "librsvg"
    args << "--without-libevent" if MacOS.version < :snow_leopard # ERROR: event_base_loop failed: Operation not supported
    args << "--without-libwebp" if build.without? "x11"

    system "./configure", *args
    system "make", "install"
    doc.install Dir["doc/*"]
  end

  test do
    system bin/"links", "-dump", "https://duckduckgo.com"
  end
end

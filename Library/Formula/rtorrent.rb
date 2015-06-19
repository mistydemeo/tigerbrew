require "formula"

class Rtorrent < Formula
  desc "Console-based BitTorrent client"
  # Both homepage and primary url have been down since at least ~April 2015
  homepage "https://github.com/rakshasa/rtorrent"
  url "https://mirrors.ocf.berkeley.edu/debian/pool/main/r/rtorrent/rtorrent_0.9.4.orig.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/r/rtorrent/rtorrent_0.9.4.orig.tar.gz"
  sha256 "bc0a2c1ee613b68f37021beaf4e64a9252f91ed06f998c1e897897c354ce7e84"
  revision 1

  depends_on "pkg-config" => :build
  depends_on "curl" if MacOS.version < :snow_leopard
  depends_on "libtorrent"
  depends_on "xmlrpc-c" => :optional

  # https://github.com/Homebrew/homebrew/issues/24132
  fails_with :clang do
    cause "Causes segfaults at startup/at random."
  end

  # https://trac.macports.org/ticket/27289
  if MacOS.version < :snow_leopard
    fails_with :gcc_4_0
    fails_with :gcc
    fails_with :llvm
  end

  # posix_memalign unavailable before Snow Leopard
  patch :p0 do
    url "https://trac.macports.org/export/124274/trunk/dports/net/libtorrent/files/no_posix_memalign.patch"
    sha1 "c507b74290f16f933da0a648645945e938a8e36d"
  end

  def install
    # Commented out since we're now marked as failing with clang - adamv
    # ENV.libstdcxx if ENV.compiler == :clang

    args = ["--disable-debug", "--disable-dependency-tracking", "--prefix=#{prefix}"]
    args << "--with-xmlrpc-c" if build.with? "xmlrpc-c"
    if MacOS.version <= :leopard
      inreplace "configure" do |s|
        s.gsub! '  pkg_cv_libcurl_LIBS=`$PKG_CONFIG --libs "libcurl >= 7.15.4" 2>/dev/null`',
          '  pkg_cv_libcurl_LIBS=`$PKG_CONFIG --libs "libcurl >= 7.15.4" | sed -e "s/-arch [^-]*/-arch $(uname -m) /" 2>/dev/null`'
      end
    end
    system "./configure", *args
    system "make"
    system "make", "install"

    doc.install "doc/rtorrent.rc"
  end
end

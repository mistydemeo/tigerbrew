class Libtorrent < Formula
  desc "BitTorrent library"
  homepage "https://github.com/rakshasa/libtorrent"
  url "http://sources.buildroot.net/libtorrent/libtorrent-0.13.6.tar.gz"
  sha256 "2838a08c96edfd936aff8fbf99ecbb930c2bfca3337dd1482eb5fccdb80d5a04"

  def pour_bottle?
    # https://github.com/Homebrew/homebrew/commit/5eb5e4499c9
    false
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "cppunit" => :build
  depends_on "pkg-config" => :build
  depends_on "openssl"

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
    # Currently can't build against libc++; see:
    # https://github.com/homebrew/homebrew/issues/23483
    # https://github.com/rakshasa/libtorrent/issues/47
    ENV.libstdcxx if ENV.compiler == :clang

    system "sh", "autogen.sh"
    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-kqueue",
                          "--enable-ipv6"
    system "make"
    system "make", "install"
  end
end

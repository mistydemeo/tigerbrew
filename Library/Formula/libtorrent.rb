require "formula"

class Libtorrent < Formula
  homepage "http://libtorrent.rakshasa.no/"
  url "http://libtorrent.rakshasa.no/downloads/libtorrent-0.13.4.tar.gz"
  sha1 "3a3ca87054d020bc376abe2c1ea15bbbaef31131"

  bottle do
    cellar :any
    revision 1
    sha1 "dad688e6891698d0d831e790dcfb15fa68fa8936" => :yosemite
    sha1 "e2e4a075b89b560db4bee7ab228560574fad1b70" => :mavericks
    sha1 "4be608f09508bc55ad1daefa8ba6960dcd636758" => :mountain_lion
  end

  depends_on "pkg-config" => :build

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
    # https://github.com/mxcl/homebrew/issues/23483
    # https://github.com/rakshasa/libtorrent/issues/47
    ENV.libstdcxx if ENV.compiler == :clang

    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-kqueue",
                          "--enable-ipv6"
    system "make"
    system "make install"
  end
end

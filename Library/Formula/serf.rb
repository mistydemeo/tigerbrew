require 'formula'

class Serf < Formula
  homepage 'http://code.google.com/p/serf/'
  url 'http://serf.googlecode.com/files/serf-1.3.0.tar.bz2'
  sha1 '14ed3e1dc195016a548499b3831f3df6b2501d27'

  option :universal

  depends_on 'homebrew/dupes/apr' if MacOS.version < :leopard
  depends_on 'homebrew/dupes/apr-util' if MacOS.version < :leopard
  depends_on :libtool
  depends_on 'scons' => :build
  depends_on 'sqlite'

  def install
    ENV.universal_binary if build.universal?
    system "scons", "PREFIX=#{prefix}", "CC=#{ENV.cc}",
      "CFLAGS=#{ENV.cflags}", "LINKFLAGS=#{ENV.ldflags}", "CPPFLAGS=#{ENV.cppflags}"
    system "scons install"
  end
end

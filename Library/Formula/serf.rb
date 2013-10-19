require 'formula'

class Serf < Formula
  homepage 'http://code.google.com/p/serf/'
  url 'http://serf.googlecode.com/files/serf-1.3.2.tar.bz2'
  sha1 '90478cd60d4349c07326cb9c5b720438cf9a1b5d'

  bottle do
    sha1 '2a34148f2f914963cdedd4c04858c9b85b09fbb6' => :mountain_lion
    sha1 '9b44078ef53c14852dbe0d7a2e8eded64c24d4bd' => :lion
    sha1 '63442a59487dba7c1e81c99bec80653e7f0ae91d' => :snow_leopard
  end

  option :universal

  depends_on :ld64
  depends_on 'homebrew/dupes/apr' if MacOS.version < :leopard
  depends_on 'homebrew/dupes/apr-util' if MacOS.version < :leopard
  depends_on :libtool
  depends_on 'sqlite'
  depends_on 'scons' => :build

  def install
    # SConstruct merges in gssapi linkflags using scons's MergeFlags,
    # but that discards duplicate values - including the duplicate
    # values we want, like multiple -arch values for a universal build.
    # Passing 0 as the `unique` kwarg turns this behaviour off.
    inreplace 'SConstruct', 'unique=1', 'unique=0'

    ENV.universal_binary if build.universal?
    # scons ignores our compiler and flags unless explicitly passed
    args = %W[PREFIX=#{prefix} GSSAPI=/usr CC=#{ENV.cc}
              CFLAGS=#{ENV.cflags} LINKFLAGS=#{ENV.ldflags}]
    if MacOS.version < :leopard
      args << "APR=#{Formula.factory('apr').opt_prefix}/bin/apr-1-config"
      args << "APU=#{Formula.factory('apr-util').opt_prefix}/bin/apu-1-config"
    end

    system "scons", *args
    system "scons install"
  end
end

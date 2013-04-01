require 'formula'

class Serf < Formula
  homepage 'http://code.google.com/p/serf/'
  url 'http://serf.googlecode.com/files/serf-1.2.0.tar.bz2'
  sha1 '30b29bd9214d50887abcc20cf82096aaaf5d1d61'

  option :universal

  depends_on 'homebrew/dupes/apr' if MacOS.version < :leopard
  depends_on 'homebrew/dupes/apr-util' if MacOS.version < :leopard
  depends_on :libtool
  depends_on 'sqlite'

  def apr_bin
    if MacOS.version < :leopard
      Formula.factory('apr').opt_prefix/'bin'
    else
      superbin or "/usr/bin"
    end
  end

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}",
                          "--with-apr=#{apr_bin}"
    system "make install"
  end
end

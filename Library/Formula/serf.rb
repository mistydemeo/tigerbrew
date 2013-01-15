require 'formula'

class Serf < Formula
  homepage 'http://code.google.com/p/serf/'
  url 'http://serf.googlecode.com/files/serf-1.1.1.tar.bz2'
  sha1 '1ec4689ef57e7c28e7371df00d0ccc3e32ef6457'

  option :universal

  depends_on :libtool
  depends_on 'apr'
  depends_on 'apr-util'

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-apr=#{HOMEBREW_PREFIX}"
    system "make install"
  end
end

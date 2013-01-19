require 'formula'

class AprUtil < Formula
  homepage 'http://apr.apache.org/'
  url 'http://archive.apache.org/dist/apr/apr-util-1.4.1.tar.bz2'
  sha1 '229a1df48822e3048ae90e2467a5c078474e99a6'

  depends_on 'apr'

  def install
    # Compilation will not complete without deparallelize
    ENV.deparallelize

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-apr=#{Formula.factory('apr').prefix}"
    system "make install"
  end

end

require 'formula'

class Apr < Formula
  homepage 'http://apr.apache.org/'
  url 'http://archive.apache.org/dist/apr/apr-1.4.6.tar.bz2'
  sha1 '1a72fc9d89a378590ef243399396169426d1f6cf'

  def install
    # Compilation will not complete without deparallelize
    ENV.deparallelize

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}"
    system "make install"
  end

end

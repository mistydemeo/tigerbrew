require 'formula'

class Libxmp < Formula
  homepage 'http://xmp.sourceforge.net'
  url 'https://downloads.sourceforge.net/project/xmp/libxmp/4.2.5/libxmp-4.2.5.tar.gz'
  sha1 '8c60ddf76366bdbd87f845a840c204a9ade2aaf3'

  head do
    url 'git://git.code.sf.net/p/xmp/libxmp'
    depends_on :autoconf
  end

  # build tries to pass -compatibility-version, which Tiger's ld doesn't grok
  # https://github.com/cmatsuoka/libxmp/issues/1
  depends_on :ld64
  # a bug in gnumake 3.80 causes the build to instantly fail
  depends_on 'homebrew/dupes/make' => :build if MacOS.version < :leopard

  def install
    system "autoconf" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end

require 'formula'

class Libxmp < Formula
  homepage 'http://xmp.sourceforge.net'
  url 'http://downloads.sourceforge.net/project/xmp/libxmp/4.1.5/libxmp-4.1.5.tar.gz'
  sha1 'f50ff6d98e9c21c8fb5e29a8c9e5677983285d90'

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
    # see https://github.com/cmatsuoka/libxmp/issues/2; fixed in next release
    inreplace 'Makefile', '-dynamiclib', '$(LDFLAGS) -dynamiclib'
    system "make install"
  end
end

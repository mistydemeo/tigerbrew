require 'formula'

class Libxmp < Formula
  homepage 'http://xmp.sourceforge.net'
  url 'http://downloads.sourceforge.net/project/xmp/libxmp/4.2.0/libxmp-4.2.0.tar.gz'
  sha1 '138599f4a29f4b25c6c812b0e226e554776a77d3'

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

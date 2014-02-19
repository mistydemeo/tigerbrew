require 'formula'

class Libxmp < Formula
  homepage 'http://xmp.sourceforge.net'
  url 'http://downloads.sourceforge.net/project/xmp/libxmp/4.2.2/libxmp-4.2.2.tar.gz'
  sha1 '54d2db955b48e5ebdcfb6809d7cab3ce146c7611'

  head do
    url 'git://git.code.sf.net/p/xmp/libxmp'
    depends_on :autoconf
  end

  # build tries to pass -compatibility-version, which Tiger's ld doesn't grok
  # https://github.com/cmatsuoka/libxmp/issues/1
  depends_on :ld64
  # a bug in gnumake 3.80 causes the build to instantly fail
  depends_on 'homebrew/dupes/make' => :build if MacOS.version < :leopard

  # Both of these patches have been applied upstream and should be in
  # the next release.
  def patches
    unless build.head?
      [
        # fixes dylib versioning
        'https://github.com/cmatsuoka/libxmp/commit/c6301dc68e1c1f6c247667df56fda754412cfb48.patch',
        # fixes replay time of S3M modules
        'https://github.com/cmatsuoka/libxmp/commit/3368bb9a4583d75e1844fad5caa964045d007179.patch'
      ]
    end
  end

  def install
    system "autoconf" if build.head?
    system "./configure", "--prefix=#{prefix}"
    # see https://github.com/cmatsuoka/libxmp/issues/2; fixed in next release
    inreplace 'Makefile', '-dynamiclib', '$(LDFLAGS) -dynamiclib'
    system "make install"
  end
end

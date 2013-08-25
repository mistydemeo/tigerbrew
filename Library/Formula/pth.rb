require 'formula'

class Pth < Formula
  homepage 'http://www.gnu.org/software/pth/'
  url 'http://ftpmirror.gnu.org/pth/pth-2.0.7.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/pth/pth-2.0.7.tar.gz'
  sha1 '9a71915c89ff2414de69fe104ae1016d513afeee'

  # see https://github.com/mistydemeo/tigerbrew/issues/106
  depends_on :ld64

  def install
    ENV.deparallelize
    # Note: shared library will not be build with --disable-debug, so don't add that flag
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          # these flags are the defaults on most platforms, but for some
                          # reason Leopard/PPC doesn't set them, resulting in test failures
                          # see: https://github.com/mistydemeo/tigerbrew/issues/39
                          "--with-mctx-mth=sjlj",
                          "--with-mctx-dsp=ssjlj",
                          "--with-mctx-stk=sas"
    system "make"
    system "make test"
    system "make install"
  end
end

class Pth < Formula
  desc "GNU Portable THreads"
  homepage "https://www.gnu.org/software/pth/"
  url "http://ftpmirror.gnu.org/pth/pth-2.0.7.tar.gz"
  mirror "https://ftp.gnu.org/gnu/pth/pth-2.0.7.tar.gz"
  sha256 "72353660c5a2caafd601b20e12e75d865fd88f6cf1a088b306a3963f0bc77232"


  # see https://github.com/mistydemeo/tigerbrew/issues/106
  depends_on :ld64

  def install
    ENV.deparallelize

    # Note: shared library will not be build with --disable-debug, so don't add that flag
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          # these flags are the defaults on most platforms, but for some
                          # reason Leopard/PPC doesn't set them, resulting in test failures
                          # see: https://github.com/mistydemeo/tigerbrew/issues/39
                          "--with-mctx-mth=sjlj",
                          "--with-mctx-dsp=ssjlj",
                          "--with-mctx-stk=sas"
    system "make"
    system "make", "test"
    system "make", "install"
  end

  test do
    system "#{bin}/pth-config", "--all"
  end
end

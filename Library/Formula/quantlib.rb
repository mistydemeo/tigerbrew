class Quantlib < Formula
  desc "Library for quantitative finance"
  homepage "http://quantlib.org/"
  url "https://downloads.sourceforge.net/project/quantlib/QuantLib/1.6.1/QuantLib-1.6.1.tar.gz"
  mirror "https://distfiles.macports.org/QuantLib/QuantLib-1.6.1.tar.gz"
  sha256 "4f90994671173ef20d2bfd34cefc79f753370d79eccafaec926db8c4b6c37870"

  head do
    url "https://github.com/lballabio/quantlib.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end


  option :cxx11

  if build.cxx11?
    depends_on "boost" => "c++11"
  else
    depends_on "boost"
  end

  def install
    ENV.cxx11 if build.cxx11?
    if build.head?
      Dir.chdir "QuantLib"
      system "./autogen.sh"
    end
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-lispdir=#{share}/emacs/site-lisp/quantlib"
    system "make", "install"
  end

  test do
    system bin/"quantlib-config", "--prefix=#{prefix}", "--libs", "--cflags"
  end
end

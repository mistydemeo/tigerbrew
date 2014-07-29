require "formula"

class Libxmp < Formula
  homepage "http://xmp.sourceforge.net"
  url "https://downloads.sourceforge.net/project/xmp/libxmp/4.2.8/libxmp-4.2.8.tar.gz"
  sha1 "7cb28f316c8991493e626dab149719a376c3501d"

  bottle do
    cellar :any
    sha1 "bf5b171d0f271890d066dee22e07a9d1a8319286" => :mavericks
    sha1 "11616c4b632afb7fb5de9388cb2707f50dc154b3" => :mountain_lion
    sha1 "275c0e98a00fce621e1801ad70628bf0a13e0dac" => :lion
  end

  head do
    url "git://git.code.sf.net/p/xmp/libxmp"
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

class Cconv < Formula
  desc "Iconv based simplified-traditional Chinese conversion tool"
  homepage "https://code.google.com/p/cconv/"
  url "https://cconv.googlecode.com/files/cconv-0.6.2.tar.gz"
  sha256 "f463da66c2ae18407441e12716f5f1c6cdea4e417ebfd475ec4c6dc6ad250c9d"


  def install
    # fix link with iconv: https://code.google.com/p/cconv/issues/detail?id=18
    inreplace "Makefile.in", "@ICONV_LIBS@", "@ICONV_LIBS@ -liconv"

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
    rm_f include/"unicode.h"
  end

  test do
    system bin/"cconv", "-l"
  end
end

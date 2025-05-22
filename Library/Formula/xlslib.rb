class Xlslib < Formula
  desc "C++/C library to construct Excel .xls files in code"
  homepage "https://sourceforge.net/projects/xlslib"
  url "https://downloads.sourceforge.net/project/xlslib/xlslib-old/xlslib-package-2.4.0.zip"
  mirror "https://dl.bintray.com/homebrew/mirror/xlslib-package-2.4.0.zip"
  sha256 "acc92e31294f91d8ac8adbbfc84f7a8917f7ad649a6c97b71c9f95c25887f840"


  def install
    cd "xlslib"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

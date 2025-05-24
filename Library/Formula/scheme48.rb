class Scheme48 < Formula
  desc "Scheme byte-code interpreter"
  homepage "http://www.s48.org/"
  url "http://s48.org/1.9.2/scheme48-1.9.2.tgz"
  sha256 "9c4921a90e95daee067cd2e9cc0ffe09e118f4da01c0c0198e577c4f47759df4"


  conflicts_with "gambit-scheme", :because => "both install `scheme-r5rs` binaries"
  conflicts_with "scsh", :because => "both install include/scheme48.h"

  def install
    ENV.O0 if ENV.compiler == :clang
    ENV.deparallelize
    system "./configure", "--prefix=#{prefix}", "--enable-gc=bibop"
    system "make"
    system "make", "install"
  end
end

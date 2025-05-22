class OpenSp < Formula
  desc "SGML parser"
  homepage "http://openjade.sourceforge.net"
  url "https://downloads.sourceforge.net/project/openjade/opensp/1.5.2/OpenSP-1.5.2.tar.gz"
  sha256 "57f4898498a368918b0d49c826aa434bb5b703d2c3b169beb348016ab25617ce"


  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--disable-doc-build",
                          "--enable-http",
                          "--enable-default-catalog=#{HOMEBREW_PREFIX}/share/sgml/catalog",
                          "--enable-default-search-path=#{HOMEBREW_PREFIX}/share/sgml"
    system "make", "pkgdatadir=#{share}/sgml/opensp", "install"
  end
end

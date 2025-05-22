class Omega < Formula
  desc "Packaged search engine for websites, built on top of Xapian"
  homepage "http://xapian.org"
  url "http://oligarchy.co.uk/xapian/1.2.18/xapian-omega-1.2.18.tar.xz"
  sha256 "528feb8021a52ab06c7833cb9ebacefdb782f036e99e7ed5342046c3a82380c2"


  depends_on "pcre"
  depends_on "xapian"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/omindex", "--db", "./test", "--url", "/", "#{share}/doc/xapian-omega"
    assert File.exist?("./test/flintlock")
  end
end

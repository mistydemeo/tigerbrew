class Liblockfile < Formula
  desc "Library providing functions to lock standard mailboxes"
  homepage "https://packages.qa.debian.org/libl/liblockfile.html"
  url "https://mirrors.kernel.org/debian/pool/main/libl/liblockfile/liblockfile_1.09.orig.tar.gz"
  mirror "http://ftp.us.debian.org/debian/pool/main/libl/liblockfile/liblockfile_1.09.orig.tar.gz"
  sha256 "16979eba05396365e1d6af7100431ae9d32f9bc063930d1de66298a0695f1b7f"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-debug",
                          "--with-mailgroup=staff",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--mandir=#{man}"
    bin.mkpath
    lib.mkpath
    include.mkpath
    man1.mkpath
    man3.mkpath
    system "make"
    system "make", "install"
  end
end

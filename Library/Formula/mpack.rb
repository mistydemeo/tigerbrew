class Mpack < Formula
  desc "MIME mail packing and unpacking"
  homepage "https://web.archive.org/web/20190220145801/http://ftp.andrew.cmu.edu/pub/mpack/"
  url "http://ftp.andrew.cmu.edu/pub/mpack/mpack-1.6.tar.gz"
  sha256 "274108bb3a39982a4efc14fb3a65298e66c8e71367c3dabf49338162d207a94c"

  # Fix missing return value; clang refuses to compile otherwise
  patch :p0 do
    url "https://trac.macports.org/export/96943/trunk/dports/mail/mpack/files/uudecode.c.patch"
    sha256 "52ad1592ee4b137cde6ddb3c26e3541fa0dcea55c53ae8b37546cd566c897a43"
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end
end

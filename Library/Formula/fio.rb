class Fio < Formula
  desc "I/O benchmark and stress test"
  homepage "http://freecode.com/projects/fio"
  url "http://brick.kernel.dk/snaps/fio-2.2.9.tar.bz2"
  sha256 "c881d9cf15500bd4436970d0467c356c5c021417131587931ba78845e965bf56"
  head "git://git.kernel.dk/fio.git"


  def install
    system "./configure"
    # fio's CFLAGS passes vital stuff around, and crushing it will break the build
    system "make", "prefix=#{prefix}",
                   "mandir=#{man}",
                   "sharedir=#{share}",
                   "CC=#{ENV.cc}",
                   "V=true", # get normal verbose output from fio's makefile
                   "install"
  end

  test do
    system "#{bin}/fio", "--parse-only"
  end
end

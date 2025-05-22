# Use a newer version instead of the upstream tarball:
# http://livestreamer.tanuki.se/en/latest/issues.html#installed-rtmpdump-does-not-support-jtv-argument
class Rtmpdump < Formula
  desc "Tool for downloading RTMP streaming media"
  homepage "https://rtmpdump.mplayerhq.hu"
  url "https://mirrors.ocf.berkeley.edu/debian/pool/main/r/rtmpdump/rtmpdump_2.4+20150115.gita107cef.orig.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/r/rtmpdump/rtmpdump_2.4%2b20150115.gita107cef.orig.tar.gz"
  version "2.4+20150115"
  sha256 "d47ef3a07815079bf73eb5d053001c4341407fcbebf39f34e6213c4b772cb29a"

  head "git://git.ffmpeg.org/rtmpdump"


  # Tiger's ld fails with:
  # "common symbols not allowed with MH_DYLIB output format with the -multi_module option"
  depends_on :ld64
  depends_on "openssl"

  fails_with :llvm do
    build 2336
    cause "Crashes at runtime"
  end

  def install
    ENV.deparallelize
    system "make", "CC=#{ENV.cc}",
                   "XCFLAGS=#{ENV.cflags}",
                   "XLDFLAGS=#{ENV.ldflags}",
                   "MANDIR=#{man}",
                   "SYS=darwin",
                   "prefix=#{prefix}",
                   "sbindir=#{bin}",
                   "install"
  end

  test do
    system "#{bin}/rtmpdump", "-h"
  end
end

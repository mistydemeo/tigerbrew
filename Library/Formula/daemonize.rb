class Daemonize < Formula
  desc "Run a command as a UNIX daemon"
  homepage "http://software.clapper.org/daemonize/"
  url "https://github.com/bmc/daemonize/archive/release-1.7.6.tar.gz"
  sha256 "8d5717ae5e5bbd4cd6687abe1310f4d817468c67b851ce95dda73038ab40db1f"


  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end

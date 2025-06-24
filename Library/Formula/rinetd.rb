class Rinetd < Formula
  desc "Internet TCP redirection server"
  homepage "http://www.boutell.com/rinetd/"
  url "http://www.boutell.com/rinetd/http/rinetd.tar.gz"
  version "0.62"
  sha256 "0c68d27c5bd4b16ce4f58a6db514dd6ff37b2604a88b02c1dfcdc00fc1059898"


  def install
    inreplace "rinetd.c" do |s|
      s.gsub! "/etc/rinetd.conf", "#{etc}/rinetd.conf"
      s.gsub! "/var/run/rinetd.pid", "#{var}/rinetd.pid"
    end

    inreplace "Makefile" do |s|
      s.gsub! "/usr/sbin", sbin
      s.gsub! "/usr/man", man
    end

    sbin.mkpath
    man8.mkpath

    system "make", "install"

    conf = etc/"rinetd.conf"
    unless conf.exist?
      conf.write <<-EOS.undent
        # forwarding rules go here
        #
        # you may specify allow and deny rules after a specific forwarding rule
        # to apply to only that forwarding rule
        #
        # bindadress bindport connectaddress connectport
      EOS
    end
  end

  test do
    system "#{sbin}/rinetd", "-h"
  end
end

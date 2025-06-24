class Udpxy < Formula
  desc "UDP-to-HTTP multicast traffic relay daemon"
  homepage "http://www.udpxy.com/"
  url "http://www.udpxy.com/download/1_23/udpxy.1.0.23-9-prod.tar.gz"
  sha256 "6ce33b1d14a1aeab4bd2566aca112e41943df4d002a7678d9a715108e6b714bd"
  version "1.0.23-9"


  # Fix gzip path in Makefile for uname Darwin, this is needed to fix the install task
  # http://sourceforge.net/p/udpxy/patches/4/
  patch :DATA

  def install
    system "make"
    system "make", "install", "DESTDIR=#{prefix}", "PREFIX=''"
  end

  plist_options :manual => "udpxy -p 4022"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/udpxy</string>
        <string>-p</string>
        <string>4022</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
    </dict>
    </plist>
    EOS
  end
end

__END__
--- a/Makefile 2014-07-31 18:40:40.000000000 +0200
+++ b/Makefile 2014-07-31 18:41:05.000000000 +0200
@@ -32,7 +32,9 @@
 ALL_FLAGS = -W -Wall -Werror --pedantic $(CFLAGS)

 SYSTEM=$(shell uname 2>/dev/null)
-ifeq ($(SYSTEM), FreeBSD)
+ifeq ($(SYSTEM), Darwin)
+GZIP := /usr/bin/gzip
+else ifeq ($(SYSTEM), FreeBSD)
 MAKE := gmake
 GZIP := /usr/bin/gzip
 endif

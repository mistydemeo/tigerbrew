class Nrpe < Formula
  desc "Nagios remote plugin executor"
  homepage "https://www.nagios.org/"
  url "https://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz"
  sha256 "66383b7d367de25ba031d37762d83e2b55de010c573009c6f58270b137131072"
  revision 1


  depends_on "nagios-plugins"
  depends_on "openssl"

  def install
    user  = `id -un`.chomp
    group = `id -gn`.chomp

    (var/"run").mkpath
    inreplace "sample-config/nrpe.cfg.in", "/var/run/nrpe.pid", var/"run/nrpe.pid"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--libexecdir=#{sbin}",
                          "--sysconfdir=#{etc}",
                          "--with-nrpe-user=#{user}",
                          "--with-nrpe-group=#{group}",
                          "--with-nagios-user=#{user}",
                          "--with-nagios-group=#{group}",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}",
                          # Set both or it still looks for /usr/lib
                          "--with-ssl-lib=#{Formula["openssl"].opt_lib}",
                          "--enable-ssl",
                          "--enable-command-args"
    system "make", "all"
    system "make", "install"
    system "make", "install-daemon-config"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>org.nrpe.agent</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{HOMEBREW_PREFIX}/bin/nrpe</string>
        <string>-c</string>
        <string>#{etc}/nrpe.cfg</string>
        <string>-d</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>ServiceDescription</key>
      <string>Homebrew NRPE Agent</string>
      <key>Debug</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  def caveats
    <<-EOS.undent
    The nagios plugin check_nrpe has been installed in:
      #{HOMEBREW_PREFIX}/sbin

    You can start the daemon with
      #{bin}/nrpe -c #{etc}/nrpe.cfg -d
    EOS
  end
end

class Bitlbee < Formula
  desc "IRC to other chat networks gateway"
  homepage "http://www.bitlbee.org/"
  url "http://get.bitlbee.org/src/bitlbee-3.4.1.tar.gz"
  sha256 "500a0b19943040d67458eb3beb0a63d004abb2aa54a777addeb2a895d4f5c0e1"

  head "https://github.com/bitlbee/bitlbee.git"


  option "with-pidgin", "Use finch/libpurple for all communication with instant messaging networks"
  option "with-libotr", "Build with otr (off the record) support"

  deprecated_option "with-finch" => "with-pidgin"

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "gnutls"
  depends_on "libgcrypt"
  depends_on "pidgin" => :optional
  depends_on "libotr" => :optional

  def install
    args = ["--prefix=#{prefix}",
            "--debug=0",
            "--ssl=gnutls",
            "--pidfile=#{var}/bitlbee/run/bitlbee.pid",
            "--config=#{var}/bitlbee/lib/",
            "--ipsocket=#{var}/bitlbee/run/bitlbee.sock"]

    args << "--purple=1" if build.with? "pidgin"
    args << "--otr=1" if build.with? "libotr"

    system "./configure", *args

    # This build depends on make running first.
    system "make"
    system "make", "install"
    # Install the dev headers too
    system "make", "install-dev"
    # This build has an extra step.
    system "make", "install-etc"

    (var+"bitlbee/run").mkpath
    (var+"bitlbee/lib").mkpath
  end

  plist_options :manual => "bitlbee -D"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>OnDemand</key>
      <true/>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/bitlbee</string>
      </array>
      <key>ServiceDescription</key>
      <string>bitlbee irc-im proxy</string>
      <key>Sockets</key>
      <dict>
        <key>Listener</key>
        <dict>
          <key>SockFamily</key>
          <string>IPv4</string>
          <key>SockProtocol</key>
          <string>TCP</string>
          <key>SockNodeName</key>
          <string>127.0.0.1</string>
          <key>SockServiceName</key>
          <string>6667</string>
          <key>SockType</key>
          <string>stream</string>
        </dict>
      </dict>
      <key>inetdCompatibility</key>
      <dict>
        <key>Wait</key>
        <false/>
      </dict>
    </dict>
    </plist>
    EOS
  end

  test do
    shell_output("#{sbin}/bitlbee -V", 1)
  end
end

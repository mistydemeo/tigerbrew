class Lldpd < Formula
  desc "Implementation library for LLDP"
  homepage "https://vincentbernat.github.io/lldpd/"
  url "http://media.luffy.cx/files/lldpd/lldpd-0.7.17.tar.gz"
  sha256 "6b50b8aa47d1424a93ba3df55af26da41f7d5718db8d25e99291c4a6cd09c20e"
  revision 1


  option "with-snmp", "Build SNMP subagent support"
  option "with-json", "Build JSON support for lldpcli"

  depends_on "pkg-config" => :build
  depends_on "readline"
  depends_on "libevent"
  depends_on "net-snmp" if build.with? "snmp"
  depends_on "jansson"  if build.with? "json"

  def install
    readline = Formula["readline"]
    args = [
      "--prefix=#{prefix}",
      "--sysconfdir=#{etc}",
      "--localstatedir=#{var}",
      "--with-xml",
      "--with-readline",
      "--with-privsep-chroot=/var/empty",
      "--with-privsep-user=nobody",
      "--with-privsep-group=nogroup",
      "--with-launchddaemonsdir=no",
      "CPPFLAGS=-I#{readline.include} -DRONLY=1",
      "LDFLAGS=-L#{readline.lib}",
    ]
    args << (build.with?("snmp") ? "--with-snmp" : "--without-snmp")
    args << (build.with?("json") ? "--with-json" : "--without-json")

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  plist_options :startup => true

  def plist
    additional_args = ""
    if build.with? "snmp"
      additional_args += "<string>-x</string>"
    end
    <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/lldpd</string>
        #{additional_args}
      </array>
      <key>RunAtLoad</key><true/>
      <key>KeepAlive</key><true/>
    </dict>
    </plist>
    EOS
  end
end

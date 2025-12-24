class Squid < Formula
  desc "Advanced proxy caching server for HTTP, HTTPS, FTP, and Gopher"
  homepage "https://www.squid-cache.org/"
  url "https://github.com/squid-cache/squid/releases/download/SQUID_6_14/squid-6.14.tar.bz2"
  sha256 "cdc6b6c1ed519836bebc03ef3a6ed3935c411b1152920b18a2210731d96fdf67"
  license "GPL-2.0-or-later"

  bottle do
  end

  # Needs a compiler with C++17 support
  fails_with :gcc
  fails_with :gcc_4_0
  fails_with :llvm

  depends_on "pkg-config" => :build
  depends_on "cyrus-sasl"
  depends_on "nettle"
  depends_on "openssl3"

  def install
    # http://stackoverflow.com/questions/20910109/building-squid-cache-on-os-x-mavericks
    ENV.append "LDFLAGS",  "-lresolv"

    # For --disable-eui, see:
    # https://www.squid-cache.org/mail-archive/squid-users/201304/0040.html
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --localstatedir=#{var}
      --enable-ssl
      --enable-ssl-crtd
      --disable-eui
      --with-included-ltdl
      --with-openssl
      --without-gnutls
    ]

    # Firewall changed in Snow Leopard
    args << "--enable-ipfw-transparent" if MacOS.version <= :leopard
    args << "--enable-pf-transparent" if MacOS.version >= :snow_leopard

    # Missing functionality from ancient Kerberos library
    args << "--without-mit-krb5" if MacOS.version < :leopard
    args << "--without-heimdal-krb5" if MacOS.version < :leopard

    system "./configure", *args
    system "make", "install"
  end

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
        <string>#{opt_sbin}/squid</string>
        <string>-N</string>
        <string>-d 1</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{var}</string>
    </dict>
    </plist>
    EOS
  end

  test do
    pid = fork do
      exec "#{sbin}/squid"
    end
    sleep 2

    begin
      system "#{sbin}/squid", "-k", "check"
    ensure
      exec "#{sbin}/squid -k interrupt"
      Process.wait(pid)
    end
  end
end

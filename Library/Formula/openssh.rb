class Openssh < Formula
  desc "OpenBSD freely-licensed SSH connectivity tools"
  homepage "https://www.openssh.com/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.6p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.6p1.tar.gz"
  version "10.6p1"
  sha256 "a9dc9565dffe8640f64d863cd29a32bc4a3dbdec0566a7fc44c5d6ee767d5f39"
  license "SSH-OpenSSH"

  bottle do
  end

  # Please don't resubmit the keychain patch option. It will never be accepted.
  # https://archive.is/hSB6d#10%25

  depends_on "pkg-config" => :build
  depends_on "ldns"
  depends_on "openssl3"
  depends_on "zlib"

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}/ssh
      --with-ldns
      --with-libedit
      --with-kerberos5
      --with-pam
      --with-ssl-dir=#{Formula["openssl3"].opt_prefix}
      --with-zlib=#{Formula["zlib"].opt_prefix}
    ]
    # Leopard renamed the privilege separation user to _sshd (Apple's own
    # sshd uses it); "sshd" is only a DirectoryService alias there.
    args << "--with-privsep-user=_sshd" if MacOS.version >= :leopard

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"

    # This was removed by upstream with very little announcement and has
    # potential to break scripts, so recreate it for now.
    # Debian have done the same thing.
    bin.install_symlink bin/"ssh" => "slogin"
  end

  plist_options :startup => true

  # Run sshd the same way Apple's com.openssh.sshd does: launchd owns the
  # socket and starts one sshd -i per connection inside a fresh session.
  # A long-running "sshd -D" under launchd breaks on Leopard: pam_launchd
  # tears down the shared bootstrap namespace when the first login ends,
  # so every later login fails in pam_open_session() and exits with 254.
  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/sshd</string>
        <string>-i</string>
        <string>-f</string>
        <string>#{etc}/ssh/sshd_config</string>
      </array>
      <key>SessionCreate</key>
      <true/>
      <key>Sockets</key>
      <dict>
        <key>Listeners</key>
        <dict>
          <key>SockServiceName</key>
          <string>ssh</string>
        </dict>
      </dict>
      <key>StandardErrorPath</key>
      <string>/dev/null</string>
      <key>inetdCompatibility</key>
      <dict>
        <key>Wait</key>
        <false/>
      </dict>
    </dict>
    </plist>
    EOS
  end

  def caveats; <<-EOS.undent
    In order to be able to use sshd, you need to enable PAM support by stating
    UsePAM yes
    in your #{etc}/ssh/sshd_config

    The launchd plist listens on port 22, so turn off Apple's sshd first
    (Remote Login in Sharing preferences, or
      sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist).
    To keep existing known_hosts entries valid, list the old host key first:
      HostKey /etc/ssh_host_rsa_key
    EOS
  end

  test do
    require "socket"
    def free_port
      server = TCPServer.new 0
      _, port, = server.addr
      server.close
      port
    end

    assert_match "OpenSSH_", shell_output("#{bin}/ssh -V 2>&1")

    port = free_port
    fork { exec sbin/"sshd", "-D", "-p", port.to_s }
    sleep 2
    assert_match "sshd", shell_output("lsof -i :#{port}")
  end
end

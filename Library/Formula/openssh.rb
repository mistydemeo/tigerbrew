class Openssh < Formula
  desc "OpenBSD freely-licensed SSH connectivity tools"
  homepage "https://www.openssh.com/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.2p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.2p1.tar.gz"
  version "10.2p1"
  sha256 "ccc42c0419937959263fa1dbd16dafc18c56b984c03562d2937ce56a60f798b2"
  license "SSH-OpenSSH"

  bottle do
    sha256 "d69009bc9e9af938192e21d804c9c5c41f3b9d25e9645f7c987eef1bb507c7c9" => :tiger_g3
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

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"

    # This was removed by upstream with very little announcement and has
    # potential to break scripts, so recreate it for now.
    # Debian have done the same thing.
    bin.install_symlink bin/"ssh" => "slogin"
  end

  def caveats; <<-EOS.undent
    In order to be able to use sshd, you need to enable PAM support by stating
    UsePAM yes
    in your #{etc}/ssh/sshd_config
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

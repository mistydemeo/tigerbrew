class Openssh < Formula
  desc "OpenBSD freely-licensed SSH connectivity tools"
  homepage "https://www.openssh.com/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.9p1.tar.gz"
  mirror "https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.9p1.tar.gz"
  version "9.9p1"
  sha256 "b343fbcdbff87f15b1986e6e15d6d4fc9a7d36066be6b7fb507087ba8f966c02"
  license "SSH-OpenSSH"

  bottle do
    sha256 "8eb6ad4ec96fc8b35a1ad6fdd3830636f5f4deb34b1c788def613be913225bbc" => :tiger_altivec
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

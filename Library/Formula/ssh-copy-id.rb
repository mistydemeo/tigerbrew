class SshCopyId < Formula
  desc "Add a public key to a remote machine's authorized_keys file"
  homepage "http://www.openssh.com/"
  url "http://ftp.usa.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.8p1.tar.gz"
  mirror "http://ftp3.usa.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.8p1.tar.gz"
  version "6.8p1"
  sha256 "3ff64ce73ee124480b5bf767b9830d7d3c03bbcb6abe716b78f0192c37ce160e"


  def install
    bin.install "contrib/ssh-copy-id"
    man1.install "contrib/ssh-copy-id.1"
  end

  test do
    shell_output bin/"ssh-copy-id -h", 1
  end
end

class Cowsay < Formula
  desc "Configurable talking characters in ASCII art"
  homepage "https://web.archive.org/web/20120225123719/http://www.nog.net/~tony/warez/cowsay.shtml"
  url "https://ftp.acc.umu.se/mirror/cdimage/snapshot/Debian/pool/main/c/cowsay/cowsay_3.03+dfsg2.orig.tar.gz"
  sha256 "3b89965c7d6b19f321867e59d14d4aec820d36068f56d2b1e783498beeb4183e"
  version "3.0.3+dfsg2"


  # Official download is 404:
  # url "http://www.nog.net/~tony/warez/cowsay-3.03.tar.gz"

  def install
    system "/bin/sh", "install.sh", prefix
    mv prefix/"man", share
  end

  test do
    output = shell_output("#{bin}/cowsay moo")
    assert output.include?("moo")  # bubble
    assert output.include?("^__^") # cow
  end
end

class Cowsay < Formula
  desc "Configurable talking characters in ASCII art"
  homepage "https://web.archive.org/web/20120225123719/http://www.nog.net/~tony/warez/cowsay.shtml"
  url "https://ftp.acc.umu.se/mirror/cdimage/snapshot/Debian/pool/main/c/cowsay/cowsay_3.03+dfsg2.orig.tar.gz"
  sha256 "3b89965c7d6b19f321867e59d14d4aec820d36068f56d2b1e783498beeb4183e"
  version "3.0.3+dfsg2"

  bottle do
    cellar :any_skip_relocation
    revision 1
    sha256 "c041ce7fbf41fd89bf620ae848e3b36fe1e69ab3e2dfca18bc2f2e79cfe8063a" => :el_capitan
    sha256 "ffacfb987481394174267fd987dea52607825e3542d1ea3d0b7aa4ccf7ea5cc5" => :yosemite
    sha256 "12c41b969af30817a4dc7ec25572fe1b707b9d4dcb46d8cc06d22264594219c1" => :mavericks
  end

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

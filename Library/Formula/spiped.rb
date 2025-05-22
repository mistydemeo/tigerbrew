class Spiped < Formula
  desc "Secure pipe daemon"
  homepage "https://www.tarsnap.com/spiped.html"
  url "https://www.tarsnap.com/spiped/spiped-1.5.0.tgz"
  sha256 "b2f74b34fb62fd37d6e2bfc969a209c039b88847e853a49e91768dec625facd7"


  depends_on "bsdmake" => :build
  depends_on "openssl"

  def install
    man1.mkpath
    system "bsdmake", "BINDIR_DEFAULT=#{bin}", "MAN1DIR=#{man1}", "install"
    doc.install "spiped/README" => "README.spiped", "spipe/README" => "README.spipe"
  end
end

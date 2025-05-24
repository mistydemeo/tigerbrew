class Btpd < Formula
  desc "BitTorrent protocol daemon"
  homepage "https://github.com/btpd/btpd"
  url "https://github.com/downloads/btpd/btpd/btpd-0.16.tar.gz"
  sha256 "296bdb718eaba9ca938bee56f0976622006c956980ab7fc7a339530d88f51eb8"

  revision 1

  depends_on "openssl"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match /Torrents can be specified/, pipe_output("#{bin}/btcli --help 2>&1")
  end
end

class Tcpdump < Formula
  desc "Command-line packet analyzer"
  homepage "https://www.tcpdump.org/"
  url "https://www.tcpdump.org/release/tcpdump-4.99.4.tar.gz"
  sha256 "0232231bb2f29d6bf2426e70a08a7e0c63a0d59a9b44863b7f5e2357a6e49fea"
  license "BSD-3-Clause"
  head "https://github.com/the-tcpdump-group/tcpdump.git", branch: "master"

  bottle do
  end

  depends_on "libpcap"
  depends_on "openssl3"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-smb",
                          "--disable-universal"
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/tcpdump --help 2>&1")
    assert_match "tcpdump version #{version}", output
    assert_match "libpcap version #{Formula["libpcap"].version}", output
    assert_match "OpenSSL #{Formula["openssl3"].version}", output
  end
end

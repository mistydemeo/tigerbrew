class Yaf < Formula
  desc "Yet another flowmeter: processes packet data from pcap(3)"
  homepage "https://tools.netsa.cert.org/yaf/"
  url "https://tools.netsa.cert.org/releases/yaf-2.7.1.tar.gz"
  sha256 "b3fbaa667ea052bdb83a6e6a5bd6529daa93f8f926fa278778716f6dfadd8e5e"


  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "libfixbuf"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    input = test_fixtures("test.pcap")
    output = `#{bin}/yaf --in #{input} | #{bin}/yafscii`
    expected = "2014-10-02 10:29:06.168 - 10:29:06.169 (0.001 sec) tcp 192.168.1.115:51613 => 192.168.1.118:80 71487608:98fc8ced S/APF:AS/APF (7/453 <-> 5/578) rtt 0 ms"
    assert_equal expected, output.strip
  end
end

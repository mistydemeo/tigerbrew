class IkeScan < Formula
  desc "Discover and fingerprint IKE hosts"
  homepage "http://www.nta-monitor.com/tools-resources/security-tools/ike-scan"
  url "http://www.nta-monitor.com/tools/ike-scan/download/ike-scan-1.9.tar.gz"
  sha256 "05d15c7172034935d1e46b01dacf1101a293ae0d06c0e14025a4507656f1a7b6"
  revision 1


  head do
    url "https://github.com/royhills/ike-scan.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  depends_on "openssl"

  def install
    system "autoreconf", "-fvi" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--with-openssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install"
  end

  test do
    # We probably shouldn't probe any host for VPN servers, so let's keep this simple.
    system bin/"ike-scan", "--version"
  end
end

class Tcpreplay < Formula
  desc "Replay saved tcpdump files at arbitrary speeds"
  homepage "http://tcpreplay.appneta.com"
  url "https://github.com/appneta/tcpreplay/releases/download/v4.1.0/tcpreplay-4.1.0.tar.gz"
  sha256 "ad285b08d7a61ed88799713c4c5d657a7a503eee832304d3a767f67efe5d1a20"


  depends_on "libdnet" => :recommended

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-debug",
                          "--prefix=#{prefix}",
                          "--enable-dynamic-link",
                          "--with-libpcap=#{MacOS.sdk_path}/usr"
    system "make", "install"
  end

  test do
    system "#{bin}/tcpreplay", "--version"
  end
end

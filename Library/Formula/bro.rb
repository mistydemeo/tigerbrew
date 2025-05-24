class Bro < Formula
  desc "Network security monitor"
  homepage "https://www.bro.org"
  url "https://www.bro.org/downloads/release/bro-2.4.tar.gz"
  sha256 "740c0d0b0bec279c2acef5e1b6b4d0016c57cd02a729f5e2924ae4a922e208b2"
  head "https://github.com/bro/bro.git"


  depends_on "cmake" => :build
  depends_on "swig" => :build
  depends_on "openssl"
  depends_on "geoip" => :recommended

  def install
    system "./configure", "--prefix=#{prefix}", "--with-openssl=#{Formula["openssl"].opt_prefix}",
                          "--localstatedir=#{var}", "--conf-files-dir=#{etc}"
    system "make", "install"
  end

  test do
    system "#{bin}/bro", "--version"
  end
end

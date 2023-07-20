class Lynx < Formula
  desc "Text-based web browser"
  homepage "http://lynx.isc.org/release/"
  url "http://invisible-mirror.net/archives/lynx/tarballs/lynx2.8.9rel.1.tar.bz2"
  version "2.8.9rel.1"
  sha256 "387f193d7792f9cfada14c60b0e5c0bff18f227d9257a39483e14fa1aaf79595"

  bottle do
    sha256 "30a681fc44b5c512910cff3b0fa016786ee0f8a69e1ae1e56597c8d2b17b0ebc" => :tiger_altivec
  end

  depends_on "openssl"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--disable-echo",
                          "--enable-default-colors",
                          "--with-zlib",
                          "--with-bzlib",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}",
                          "--enable-ipv6"
    system "make", "install"
  end

  test do
    system "#{bin}/lynx", "-dump", "http://checkip.dyndns.org"
  end
end

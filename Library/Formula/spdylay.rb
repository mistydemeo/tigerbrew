class Spdylay < Formula
  desc "Experimental implementation of SPDY protocol versions 2, 3, and 3.1"
  homepage "https://github.com/tatsuhiro-t/spdylay"
  url "https://github.com/tatsuhiro-t/spdylay/archive/v1.3.2.tar.gz"
  sha256 "24f22378ffce6bd6e7e5ec69d44f3139ee102b1af59c39cddb5e6eadaf2484f8"


  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "libevent" => :recommended
  depends_on "libxml2"
  depends_on "openssl"

  def install
    system "autoreconf -i"
    system "automake"
    system "autoconf"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/spdycat", "-ns", "https://www.google.com"
  end
end

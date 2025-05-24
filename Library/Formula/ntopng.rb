class Ntopng < Formula
  desc "Next generation version of the original ntop"
  homepage "http://www.ntop.org/products/ntop/"
  url "https://downloads.sourceforge.net/project/ntop/ntopng/ntopng-2.0.tar.gz"
  sha256 "3cbfd6de1bc44d65f7c7f0de282d122d11f493f1261ba137c3b5b202e08e0251"


  head do
    url "https://github.com/ntop/ntopng.git", :branch => "dev"

    resource "nDPI" do
      url "https://github.com/ntop/nDPI.git", :branch => "dev"
    end
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "json-glib" => :build
  depends_on "wget" => :build
  depends_on "zeromq" => :build
  depends_on "gnutls" => :build

  depends_on "json-c"
  depends_on "rrdtool"
  depends_on "luajit"
  depends_on "geoip"
  depends_on "redis"

  def install
    if build.head?
      resource("nDPI").stage do
        system "./autogen.sh"
        system "make"
        (buildpath/"nDPI").install Dir["*"]
      end
    end
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/ntopng", "-h"
  end
end

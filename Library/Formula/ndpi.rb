class Ndpi < Formula
  desc "Deep Packet Inspection (DPI) library"
  homepage "http://www.ntop.org/products/ndpi/"
  url "https://downloads.sourceforge.net/project/ntop/nDPI/nDPI-1.7.tar.gz"
  sha256 "714b745103a072462130b0e14cf31b2eb5270f580b7c839da5cf5ea75150262d"


  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "json-c"

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/ndpiReader", "-i", test_fixtures("test.pcap")
  end
end

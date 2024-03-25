class Ipv6calc < Formula
  desc "Small utility for manipulating IPv6 addresses"
  homepage "http://www.deepspace6.net/projects/ipv6calc.html"
  url "https://github.com/pbiering/ipv6calc/archive/refs/tags/4.2.0.tar.gz"
  sha256 "767dbd3d21d04e21aa9764275e2aae726f04daf66bca21fc65f0a652bdc8b50e"

  bottle do
    cellar :any
    sha256 "e780bde151c4dc801dd666311ab2de24826e2daca15d2fc8bbdde32e97ca30b5" => :tiger_altivec
  end

  depends_on "openssl3"

  def install
    # This needs --mandir, otherwise it tries to install to /share/man/man8.
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}", "--datadir=#{pkgshare}"
    system "make"
    system "make", "install"
  end

  test do
    assert_equal "192.168.251.97",
      shell_output("#{bin}/ipv6calc -q --action conv6to4 --in ipv6 2002:c0a8:fb61::1 --out ipv4").strip
  end
end

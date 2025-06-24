class Dropbear < Formula
  desc "Small SSH server/client for POSIX-based system"
  homepage "https://matt.ucc.asn.au/dropbear/dropbear.html"
  url "https://matt.ucc.asn.au/dropbear/releases/dropbear-2015.68.tar.bz2"
  mirror "https://dropbear.nl/mirror/dropbear-2015.68.tar.bz2"
  sha256 "55ea7c1e904ffe4b1cdbe1addca8291a2533d7d285fd22ac33608e9502a62446"


  head do
    url "https://github.com/mkj/dropbear.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  def install
    ENV.deparallelize

    if build.head?
      system "autoconf"
      system "autoheader"
    end
    system "./configure", "--prefix=#{prefix}",
                          "--enable-pam",
                          "--enable-zlib",
                          "--enable-bundled-libtom",
                          "--sysconfdir=#{etc}/dropbear"
    system "make"
    system "make", "install"
  end

  test do
    system "dbclient", "-h"
    system "dropbearkey", "-t", "ecdsa",
           "-f", testpath/"testec521", "-s", "521"
    File.exist? testpath/"testec521"
  end
end

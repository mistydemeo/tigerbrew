class Liboping < Formula
  desc "C library to generate ICMP echo requests"
  homepage "http://noping.cc"
  url "http://noping.cc/files/liboping-1.8.0.tar.bz2"
  sha256 "1dcb9182c981b31d67522ae24e925563bed57cf950dc681580c4b0abb6a65bdb"


  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats
    "Run oping and noping sudo'ed in order to avoid the 'Operation not permitted'"
  end
end

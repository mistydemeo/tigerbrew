class Ctail < Formula
  desc "Tool for operating tail across large clusters of machines"
  homepage "https://github.com/pquerna/ctail"
  url "https://github.com/pquerna/ctail/archive/ctail-0.1.0.tar.gz"
  sha256 "864efb235a5d076167277c9f7812ad5678b477ff9a2e927549ffc19ed95fa911"


  conflicts_with "byobu", :because => "both install `ctail` binaries"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug"
    system "make", "LIBTOOL=glibtool --tag=CC"
    system "make", "install"
  end
end

class Libiscsi < Formula
  desc "Client library and utilities for iscsi"
  homepage "https://github.com/sahlberg/libiscsi"
  url "https://sites.google.com/site/libiscsitarballs/libiscsitarballs/libiscsi-1.15.0.tar.gz"
  sha256 "26aa5583053d4fe0d4686f76a76c216c7dce00130f008e652ece305b88758ff1"
  head "https://github.com/sahlberg/libiscsi.git"


  option "with-noinst", "Install the noinst binaries (e.g. iscsi-test-cu)"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "cunit" if build.with? "noinst"
  depends_on "popt"

  def install
    if build.with? "noinst"
      # Install the noinst binaries
      inreplace "Makefile.am", "noinst_PROGRAMS +=", "bin_PROGRAMS +="
    end

    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end

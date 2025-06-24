class Powerman < Formula
  desc "Control (remotely and in parallel) switched power distribution units"
  homepage "https://code.google.com/p/powerman/"
  url "https://github.com/chaos/powerman/releases/download/2.3.20/powerman-2.3.20.tar.gz"
  sha256 "a4b0858d1214aab18e2673596b00ac9bad976cb7b777209e10732467c3551b88"
  revision 1


  head do
    url "https://github.com/chaos/powerman.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "without-curl", "Omits httppower"
  option "with-net-snmp", "Builds snmppower"

  depends_on "curl" => :recommended
  depends_on "net-snmp" => :optional
  depends_on "genders" => :optional

  def install
    args = [
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
      "--localstatedir=#{var}"
    ]

    args << (build.with?("curl") ? "--with-httppower" : "--without-httppower")
    args << (build.with?("net-snmp") ? "--with-snmppower" : "--without-snmppower")
    args << (build.with?("genders") ? "--with-genders" : "--without-genders")
    args << "--with-ncurses"
    args << "--without-tcp-wrappers"

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    system "#{sbin}/powermand", "-h"
  end
end

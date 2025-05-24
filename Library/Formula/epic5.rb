class Epic5 < Formula
  desc "Enhanced, programmable IRC client"
  homepage "http://www.epicsol.org/"
  url "http://ftp.epicsol.org/pub/epic/EPIC5-PRODUCTION/epic5-1.2.0.tar.xz"
  sha256 "cfdbc1fcbe75e5441adcb7ef9ca5b1d6827815d358a38db60d1448964c2513da"

  head "http://git.epicsol.org/epic5.git"


  devel do
    url "http://ftp.epicsol.org/pub/epic/EPIC5-PRODUCTION/epic5-1.4.tar.xz"
    sha256 "3bc04e07768040db266667513158d2c640544abb49cbab29343f6ef05ebd621e"
  end

  depends_on "openssl"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--with-ipv6",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install"
  end

  test do
    connection = fork do
      exec bin/"epic5", "irc.freenode.net"
    end
    sleep 5
    Process.kill("TERM", connection)
  end
end

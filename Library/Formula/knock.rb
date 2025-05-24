class Knock < Formula
  desc "Port-knock server"
  homepage "http://www.zeroflux.org/projects/knock"
  url "http://www.zeroflux.org/proj/knock/files/knock-0.7.tar.gz"
  sha256 "9938479c321066424f74c61f6bee46dfd355a828263dc89561a1ece3f56578a4"


  head do
    url "https://github.com/jvinet/knock.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  def install
    system "autoreconf", "-fi" if build.head?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/knock", "localhost", "123:tcp"
  end
end

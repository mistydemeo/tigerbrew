class Gdnsd < Formula
  desc "Authoritative-only DNS server"
  homepage "http://gdnsd.org/"
  url "https://github.com/gdnsd/gdnsd/releases/download/v2.2.1/gdnsd-2.2.1.tar.xz"
  sha256 "dd78ff355704b2da9dd064efb0cb78b16b58020843d07dc0403684b2afe2d4c0"


  head do
    url "https://github.com/gdnsd/gdnsd.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "libev"
  depends_on "ragel"
  depends_on "libunwind-headers" => :recommended

  def install
    system "autoreconf", "-fvi" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-rundir=#{var}/run",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}",
                          "--without-urcu"
    system "make", "install"
  end

  test do
    (testpath/"config").write("options => { listen => [ 127.0.0.1 ] }")
    system "#{sbin}/gdnsd", "-c", testpath, "checkconf"
  end
end

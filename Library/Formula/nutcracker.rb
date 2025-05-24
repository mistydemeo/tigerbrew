class Nutcracker < Formula
  desc "Proxy for memcached and redis"
  homepage "https://github.com/twitter/twemproxy"
  url "https://github.com/twitter/twemproxy/archive/v0.4.0.tar.gz"
  sha256 "5f417fa3f03ac20fc5e9b36d831df107b00db90795a8155c1e66e2c38248ab13"
  head "https://github.com/twitter/twemproxy.git"


  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build

  def install
    system "autoreconf", "-ivf"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"

    (share+"nutcracker").install "conf",  "notes", "scripts"
  end

  test do
    system "#{opt_sbin}/nutcracker", "-V"
  end
end

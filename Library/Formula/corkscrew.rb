class Corkscrew < Formula
  desc "Tunnel SSH through HTTP proxies"
  homepage "https://web.archive.org/web/20160412000407/http://www.agroman.net/corkscrew/"
  url "http://www.agroman.net/corkscrew/corkscrew-2.0.tar.gz"
  sha256 "0d0fcbb41cba4a81c4ab494459472086f377f9edb78a2e2238ed19b58956b0be"

  bottle do
    cellar :any
    sha256 "5a0916aa242a22808bbbb652664f1e44620c1c78b896982f67c9a5a1b85a5efc" => :yosemite
    sha256 "79ca3f19c2a8df1cd7b43410ab600d32c4fc7038f99998acb656e5cc61807f25" => :mavericks
    sha256 "8844bb407417189b8ded9d8843017a86306f7832b776906d18db5817503faa84" => :mountain_lion
  end

  depends_on "libtool" => :build

  def install
    cp Dir["#{Formula["libtool"].opt_share}/libtool/*/config.{guess,sub}"], buildpath
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    require "open3"
    require "webrick"
    require "webrick/httpproxy"

    pid = fork do
      proxy = WEBrick::HTTPProxyServer.new :Port => 8080
      proxy.start
    end

    sleep 1

    begin
      Open3.popen3("#{bin}/corkscrew 127.0.0.1 8080 www.google.com 80") do |stdin, stdout, _|
        stdin.write "GET /index.html HTTP/1.1\r\n\r\n"
        assert_match "HTTP/1.1", stdout.gets("\r\n\r\n")
      end
    ensure
      Process.kill 9, pid
      Process.wait pid
    end
  end
end

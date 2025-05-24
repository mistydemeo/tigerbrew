class Trafficserver < Formula
  desc "HTTP/1.1 compliant caching proxy server"
  homepage "https://trafficserver.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=trafficserver/trafficserver-5.3.1.tar.bz2"
  mirror "https://archive.apache.org/dist/trafficserver/trafficserver-5.3.1.tar.bz2"
  sha256 "e6c33c7cfb629406a320a61217e08db3123cfe4b77c2eaef0eaa520065dbeb43"
  revision 1


  head do
    url "https://github.com/apache/trafficserver.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool"  => :build
  end

  option "with-spdy", "Build with SPDY protocol support"
  option "with-experimental-plugins", "Enable experimental plugins"

  depends_on "openssl"
  depends_on "pcre"
  if build.with? "spdy"
    depends_on "spdylay"
    depends_on "pkg-config" => :build
  end

  needs :cxx11

  def install
    ENV.cxx11
    # Needed for correct ./configure detections.
    ENV.enable_warnings
    # Needed for OpenSSL headers on Lion.
    ENV.append_to_cflags "-Wno-deprecated-declarations"
    system "autoreconf", "-fvi" if build.head?
    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--with-openssl=#{Formula["openssl"].opt_prefix}",
      "--with-user=#{ENV["USER"]}",
      "--with-group=admin"
    ]
    args << "--enable-spdy" if build.with? "spdy"
    args << "--enable-experimental-plugins" if build.with? "experimental-plugins"
    system "./configure", *args
    # Fix wrong username in the generated startup script for bottles.
    inreplace "rc/trafficserver.in", "@pkgsysuser@", "$USER"
    if build.with? "experimental-plugins"
      # Disable mysql_remap plugin due to missing symbol compile error:
      # https://issues.apache.org/jira/browse/TS-3490
      inreplace "plugins/experimental/Makefile", " mysql_remap", ""
    end
    system "make" if build.head?
    system "make", "install"
  end

  test do
    assert_match "Apache Traffic Server is not running.", shell_output("#{bin}/trafficserver status").chomp
  end
end

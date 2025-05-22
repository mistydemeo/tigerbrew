class Httperf < Formula
  desc "Tool for measuring webserver performance"
  homepage "https://code.google.com/p/httperf/"
  url "https://httperf.googlecode.com/files/httperf-0.9.0.tar.gz"
  sha256 "e1a0bf56bcb746c04674c47b6cfa531fad24e45e9c6de02aea0d1c5f85a2bf1c"
  revision 1


  # Upstream actually recommend using head over stable now.
  head do
    url "http://httperf.googlecode.com/svn/trunk/"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  deprecated_option "enable-debug" => "with-debug"

  option "with-debug", "Build with debugging support"

  depends_on "openssl"

  def install
    args = ["--prefix=#{prefix}",
            "--disable-dependency-tracking"]

    args << "--enable-debug" if build.with? "debug"

    if build.head?
      cd "httperf"
      # Shipped permissions = Access to configure.ac denied.
      # Probably no chance of this being fixed upstream.
      chmod 0755, "configure.ac"
      system "autoreconf", "-i"
    end
    system "./configure", *args
    system "make", "install"
  end
end

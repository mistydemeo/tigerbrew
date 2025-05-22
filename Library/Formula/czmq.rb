class Czmq < Formula
  desc "High-level C binding for ZeroMQ"
  homepage "http://czmq.zeromq.org/"
  url "https://github.com/zeromq/czmq/releases/download/v3.0.2/czmq-3.0.2.tar.gz"
  sha256 "8bca39ab69375fa4e981daf87b3feae85384d5b40cef6adbe9d5eb063357699a"
  revision 1


  head do
    url "https://github.com/zeromq/czmq.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  depends_on "pkg-config" => :build
  depends_on "libsodium" => :optional

  if build.with? "libsodium"
    depends_on "zeromq" => "with-libsodium"
  else
    depends_on "zeromq"
  end

  def install
    ENV.universal_binary if build.universal?

    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]
    args << "--with-libsodium" if build.with? "libsodium"

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
    rm Dir["#{bin}/*.gsl"]

    # makecert clashes with Mono. Rename it less generically.
    mv bin/"makecert", bin/"czmq-makecert"
  end
end

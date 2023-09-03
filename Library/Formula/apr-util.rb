class AprUtil < Formula
  desc "Companion library to apr, the Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=apr/apr-util-1.6.3.tar.bz2"
  sha256 "a41076e3710746326c3945042994ad9a4fcac0ce0277dd8fea076fec3c9772b5"

  bottle do
    sha256 "a6c899235a89ad4ce2f1edd3b999a9ee80081d33eda75c4a219acb6f7db9aaa6" => :tiger_altivec
  end

  keg_only :provided_by_osx, "Apple's CLT package contains apr."

  option :universal

  depends_on "apr"
  depends_on "expat" if MacOS.version < :tiger
  depends_on "openssl"
  depends_on "postgresql" => :optional

  def install
    ENV.universal_binary if build.universal?

    # Stick it in libexec otherwise it pollutes lib with a .exp file.
    args = %W[
      --prefix=#{libexec}
      --with-apr=#{Formula["apr"].opt_prefix}
      --with-openssl=#{Formula["openssl"].opt_prefix}
    ]

    args << "--with-pgsql=#{Formula["postgresql"].opt_prefix}" if build.with? "postgresql"

    system "./configure", *args
    system "make"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/apu-1-config", "--link-libtool", "--libs"
  end
end

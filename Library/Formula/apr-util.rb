class AprUtil < Formula
  desc "Companion library to apr, the Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=apr/apr-util-1.5.4.tar.bz2"
  sha256 "a6cf327189ca0df2fb9d5633d7326c460fe2b61684745fd7963e79a6dd0dc82e"
  revision 1

  bottle do
    sha256 "4f38f40032b9d1583249614223acfc0520e7000e8804dfedd2e0ad8b0f20defc" => :tiger_altivec
    sha256 "00de6007379bd4246825cdabc7c4eea0da4e5d2c97a545977fbe01782997869f" => :leopard_g3
    sha256 "e1f4b891239cef8a1eda4a7e22d36e3dbe8648b8db162e6a6d210874aa0c3957" => :leopard_altivec
  end

  keg_only :provided_by_osx, "Apple's CLT package contains apr."

  option :universal

  depends_on "apr"
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

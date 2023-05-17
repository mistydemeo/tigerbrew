class Apr < Formula
  desc "Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=apr/apr-1.7.4.tar.bz2"
  sha256 "fc648de983f3a2a6c9e78dea1f180639bd2fad6c06d556d4367a701fe5c35577"

  bottle do
    sha256 "e7ce8b6f59d1b41c8fd5e2f51a6871bac464d03e943e9e23fd4b947076912c42" => :tiger_altivec
    sha256 "3ae92c725f0c8ad9aa5b1044b332b76eeecc4a9831d41450c55bdd17577b626e" => :leopard_g3
    sha256 "0720fdf5a6be0810571ed9b03a67b8fef9e730d6bd1889ffc7e6e3dcbcbc3130" => :leopard_altivec
  end

  keg_only :provided_by_osx, "Apple's CLT package contains apr."

  option :universal

  def install
    ENV.universal_binary if build.universal?

    # Stick it in libexec otherwise it pollutes lib with a .exp file.
    system "./configure", "--prefix=#{libexec}"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/apr-1-config", "--link-libtool", "--libs"
  end
end

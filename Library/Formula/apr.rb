class Apr < Formula
  desc "Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=apr/apr-1.7.4.tar.bz2"
  sha256 "fc648de983f3a2a6c9e78dea1f180639bd2fad6c06d556d4367a701fe5c35577"

  bottle do
    sha256 "ed0e835943921e6bcf6c885069ffc4e6c74753217d7f0936fa4e2d7389af09f9" => :tiger_altivec
  end

  keg_only :provided_by_osx, "Apple's CLT package contains apr."

  option :universal

  def install
    ENV.universal_binary if build.universal?
    ENV.deparallelize

    # Stick it in libexec otherwise it pollutes lib with a .exp file.
    system "./configure", "--prefix=#{libexec}"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/apr-1-config", "--link-libtool", "--libs"
  end
end

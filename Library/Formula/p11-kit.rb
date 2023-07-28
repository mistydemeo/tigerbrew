class P11Kit < Formula
  desc "Library to load and enumerate PKCS# 11 modules"
  homepage "http://p11-glue.freedesktop.org"
  url "https://github.com/p11-glue/p11-kit/releases/download/0.24.1/p11-kit-0.24.1.tar.xz"
  sha256 "d8be783efd5cd4ae534cee4132338e3f40f182c3205d23b200094ec85faaaef8"

  option :universal

  depends_on "pkg-config" => :build
  depends_on "libtasn1"
  depends_on "libffi"

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-trust-module"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    system "#{bin}/p11-kit", "list-modules"
  end
end

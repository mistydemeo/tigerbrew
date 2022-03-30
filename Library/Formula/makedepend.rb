class Makedepend < Formula
  desc "Creates dependencies in makefiles"
  homepage "http://x.org"
  url "http://xorg.freedesktop.org/releases/individual/util/makedepend-1.0.5.tar.bz2"
  sha256 "f7a80575f3724ac3d9b19eaeab802892ece7e4b0061dd6425b4b789353e25425"

  bottle do
    cellar :any
    sha256 "3efbcf3b698bdb45bb01841b909da92d418c1e9f117f430c56e84aef1813436e" => :tiger_g4e
    sha256 "85f976b7a87a58d4d2eb580bfadca0587bc6ec1fe3a067a27d19c8828704090f" => :leopard_g4e
  end

  depends_on "pkg-config" => :build

  resource "xproto" do
    url "http://xorg.freedesktop.org/releases/individual/proto/xproto-7.0.25.tar.bz2"
    sha256 "92247485dc4ffc3611384ba84136591923da857212a7dc29f4ad7797e13909fe"
  end

  resource "xorg-macros" do
    url "http://xorg.freedesktop.org/releases/individual/util/util-macros-1.18.0.tar.bz2"
    sha256 "e5e3d132a852f0576ea2cf831a9813c54a58810a59cdb198f56b884c5a78945b"
  end

  def install
    resource("xproto").stage do
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{buildpath}/xproto"
      system "make", "install"
    end

    resource("xorg-macros").stage do
      system "./configure", "--prefix=#{buildpath}/xorg-macros"
      system "make", "install"
    end

    ENV.append_path "PKG_CONFIG_PATH", "#{buildpath}/xproto/lib/pkgconfig"
    ENV.append_path "PKG_CONFIG_PATH", "#{buildpath}/xorg-macros/share/pkgconfig"

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    touch "Makefile"
    system "#{bin}/makedepend"
  end
end

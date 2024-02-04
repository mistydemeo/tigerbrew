class Makedepend < Formula
  desc "Creates dependencies in makefiles"
  homepage "http://x.org"
  url "https://www.x.org/releases/individual/util/makedepend-1.0.8.tar.xz"
  sha256 "bfb26f8025189b2a01286ce6daacc2af8fe647440b40bb741dd5c397572cba5b"

  bottle do
    cellar :any_skip_relocation
    sha256 "1e38394e12dbf476b306b6b2e83751cea0863fc2fc68df9ee4f5c34ba4c227c1" => :tiger_altivec
  end

  depends_on "pkg-config" => :build

  resource "xproto" do
    url "https://www.x.org/releases/individual/proto/xproto-7.0.31.tar.bz2"
    sha256 "c6f9747da0bd3a95f86b17fb8dd5e717c8f3ab7f0ece3ba1b247899ec1ef7747"
  end

  resource "xorg-macros" do
    url "https://www.x.org/releases/individual/util/util-macros-1.20.0.tar.xz"
    sha256 "0b86b262dbe971edb4ff233bc370dfad9f241d09f078a3f6d5b7f4b8ea4430db"
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

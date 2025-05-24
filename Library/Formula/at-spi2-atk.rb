class AtSpi2Atk < Formula
  desc "Accessibility Toolkit GTK+ module"
  homepage "http://a11y.org"
  url "https://download.gnome.org/sources/at-spi2-atk/2.14/at-spi2-atk-2.14.1.tar.xz"
  sha256 "058f34ea60edf0a5f831c9f2bdd280fe95c1bcafb76e466e44aa0fb356d17bcb"


  depends_on "pkg-config" => :build
  depends_on "at-spi2-core"
  depends_on "atk"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end

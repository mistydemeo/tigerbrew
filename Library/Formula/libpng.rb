require "formula"

class Libpng < Formula
  homepage "http://www.libpng.org/pub/png/libpng.html"
  url "https://downloads.sf.net/project/libpng/libpng16/1.6.13/libpng-1.6.13.tar.xz"
  sha1 "5ae32b6b99cef6c5c85feab8edf9d619e1773b15"

  bottle do
    cellar :any
    sha1 "fca31924787944e549a5dc306693dbd69f3d28f2" => :tiger_g3
    sha1 "c348a940f1f84127267ef986506609cbcaed10f2" => :tiger_altivec
    sha1 "2238063b6420c3bd3fa530b195d8b981ee4aaf4d" => :leopard_g3
    sha1 "91f3ec294bdf0328fc34aff404b6092ba916ddf1" => :leopard_altivec
  end

  keg_only :provided_pre_mountain_lion

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make install"
  end
end

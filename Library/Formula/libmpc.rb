require 'formula'

class Libmpc < Formula
  homepage 'http://multiprecision.org'
  url 'http://ftpmirror.gnu.org/mpc/mpc-1.0.2.tar.gz'
  mirror 'http://multiprecision.org/mpc/download/mpc-1.0.2.tar.gz'
  sha1 '5072d82ab50ec36cc8c0e320b5c377adb48abe70'

  bottle do
    cellar :any
    sha1 "5eb876ffc0e9d52b686547df03f8246dec573a51" => :tiger_altivec
    sha1 "7f36073d05b6d080f98c518f06e18cab25366bb6" => :leopard_g3
    sha1 "25110c046286cac72faf3f2554f570e984d44dde" => :leopard_altivec
  end

  depends_on 'gmp'
  depends_on 'mpfr'

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}"
    ]

    system "./configure", *args
    system "make"
    system "make check"
    system "make install"
  end
end

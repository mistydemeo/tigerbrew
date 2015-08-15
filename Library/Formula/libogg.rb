class Libogg < Formula
  desc "Ogg Bitstream Library"
  homepage "https://www.xiph.org/ogg/"
  url "http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz"
  sha256 "e19ee34711d7af328cb26287f4137e70630e7261b17cbe3cd41011d73a654692"

  bottle do
    cellar :any
    sha256 "771d905c7cd8ec9b28e94ddb751e2af5e86e943ce1e156ead529b0e6f6044914" => :leopard_g3
    sha256 "f5eff6ed4b72ec948f42dee65463623fb4e61094e96abc78af8e1669633f9c4f" => :leopard_altivec
  end

  head do
    url "https://svn.xiph.org/trunk/ogg"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    ENV.deparallelize
    system "make", "install"
  end
end

class Lzo < Formula
  desc "Real-time data compression library"
  homepage "http://www.oberhumer.com/opensource/lzo/"
  url "http://www.oberhumer.com/opensource/lzo/download/lzo-2.09.tar.gz"
  sha256 "f294a7ced313063c057c504257f437c8335c41bfeed23531ee4e6a2b87bcb34c"

  bottle do
    cellar :any
    sha256 "1b87a121fe67fc2f843dca0e0dd6007089de6c43d5970c11f7b1ac3a2e30e04f" => :leopard_g3
    sha256 "f8e42b1e3d1c14a5cc987fb8e2a4050b6a581b309a91a16dbeb27c1b25b48f45" => :leopard_altivec
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"
    system "make"
    system "make", "check"
    system "make", "install"
  end
end

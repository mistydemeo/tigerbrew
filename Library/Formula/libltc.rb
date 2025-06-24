class Libltc < Formula
  desc "POSIX-C Library for handling Linear/Logitudinal Time Code (LTC)"
  homepage "https://x42.github.io/libltc/"
  url "https://github.com/x42/libltc/releases/download/v1.1.4/libltc-1.1.4.tar.gz"
  sha256 "7d9c43601190b2702de03080cf9cd1c314c523b09d19aa4ac0d08610d7075a75"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end

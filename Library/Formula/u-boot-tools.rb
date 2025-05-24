class UBootTools < Formula
  desc "Universal boot loader"
  homepage "http://www.denx.de/wiki/U-Boot/"
  url "ftp://ftp.denx.de/pub/u-boot/u-boot-2015.01.tar.bz2"
  sha256 "383051a656ebe11757b17d38a3326387e4a1b0949ca8a9e8ee506bf71dac9fde"


  depends_on "openssl"

  def install
    system "make", "sandbox_defconfig"
    system "make", "tools"
    bin.install "tools/mkimage"
    man1.install "doc/mkimage.1"
  end

  test do
    system bin/"mkimage", "-V"
  end
end

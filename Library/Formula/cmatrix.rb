class Cmatrix < Formula
  desc "Console Matrix"
  homepage "http://www.asty.org/cmatrix/"
  url "http://www.asty.org/cmatrix/dist/cmatrix-1.2a.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/c/cmatrix/cmatrix_1.2a.orig.tar.gz"
  sha256 "1fa6e6caea254b6fe70a492efddc1b40ad7ccb950a5adfd80df75b640577064c"


  def install
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/cmatrix", "-V"
  end
end

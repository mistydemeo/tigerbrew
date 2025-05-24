class Adns < Formula
  desc "C/C++ resolver library and DNS resolver utilities"
  homepage "http://www.chiark.greenend.org.uk/~ian/adns/"
  url "http://www.chiark.greenend.org.uk/~ian/adns/ftp/adns-1.5.0.tar.gz"
  sha256 "7fc5eb4d315111a3a3a3f45ff143339ad4050185fbe6bff687f21364cb4ae841"
  head "git://git.chiark.greenend.org.uk/~ianmdlvl/adns.git"


  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dynamic"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/adnsheloex", "--version"
  end
end

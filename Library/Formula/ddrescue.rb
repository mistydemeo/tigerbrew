class Ddrescue < Formula
  desc "GNU data recovery tool"
  homepage "https://www.gnu.org/software/ddrescue/ddrescue.html"
  url "http://ftpmirror.gnu.org/ddrescue/ddrescue-1.27.tar.lz"
  mirror "https://ftp.gnu.org/gnu/ddrescue/ddrescue-1.27.tar.lz"
  sha256 "38c80c98c5a44f15e53663e4510097fd68d6ec20758efdf3a925037c183232eb"

  bottle do
    sha256 "817916afa65a7f92c8a489634d947e9968a42ff63210a7049023e04265531a0a" => :tiger_altivec
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "CXX=#{ENV.cxx}"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    system bin/"ddrescue", "--force", "--size=64Ki", "/dev/zero", "/dev/null"
  end
end

class Ddrescue < Formula
  desc "GNU data recovery tool"
  homepage "https://www.gnu.org/software/ddrescue/ddrescue.html"
  url "http://ftpmirror.gnu.org/ddrescue/ddrescue-1.29.tar.lz"
  mirror "https://ftp.gnu.org/gnu/ddrescue/ddrescue-1.29.tar.lz"
  sha256 "01a414327853b39fba2fd0ece30f7bee2e9d8c8e8eb314318524adf5a60039a3"

  bottle do
    sha256 "d9f5aff0a3004017dc1612fb06b00350d8e0a10a0269a68fdecbece00d721abc" => :tiger_g3
  end

  option "with-tests", "Build and run the test suite"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "CXX=#{ENV.cxx}"
    system "make"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end

  test do
    system bin/"ddrescue", "--force", "--size=64Ki", "/dev/zero", "/dev/null"
  end
end

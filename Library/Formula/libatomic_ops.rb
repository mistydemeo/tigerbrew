class LibatomicOps < Formula
  desc "Implementations for atomic memory update operations"
  homepage "https://github.com/ivmai/libatomic_ops/"
  url "https://github.com/ivmai/libatomic_ops/releases/download/v7.8.0/libatomic_ops-7.8.0.tar.gz"
  sha256 "15676e7674e11bda5a7e50a73f4d9e7d60452271b8acf6fd39a71fefdf89fa31"

  bottle do
    sha256 "f84912cc7945b0be19837621bac395d883ccd764c111431be32ce11fff4dbb05" => :tiger_altivec
  end

  option "with-tests", "Build and run the test suite"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "check" if build.with?("tests") || build.bottle?
    system "make", "install"
  end
end

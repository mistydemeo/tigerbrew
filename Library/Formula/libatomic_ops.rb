class LibatomicOps < Formula
  desc "Implementations for atomic memory update operations"
  homepage "https://github.com/ivmai/libatomic_ops/"
  url "http://www.ivmaisoft.com/_bin/atomic_ops/libatomic_ops-7.4.2.tar.gz"
  sha256 "04fa615f62992547bcbda562260e28b504bc4c06e2f985f267f3ade30304b5dd"

  bottle do
    cellar :any_skip_relocation
    sha256 "ab9fd979995caeea176d81867fe3fb131aeecaa2db4713a4bbd193089100edc3" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "check"
    system "make", "install"
  end
end
